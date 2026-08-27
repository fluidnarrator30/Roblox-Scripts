local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local Players: Players = GetService('Players')
local RunService: RunService = GetService('RunService')
local ReplicatedStorage: ReplicatedStorage = GetService('ReplicatedStorage')
local PathfindingService: PathfindingService = GetService('PathfindingService')
local TweenService: TweenService = GetService('TweenService')

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib
local ObjectFunctions = TidalWave.Libraries.ObjectFunctions
local Modules = TidalWave.Modules

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local Combat = Categories.Combat
local PlayerCategory = Categories.Player
local Movement = Categories.Movement
local Visuals = Categories.Visuals
local World = Categories.World
local Other = Categories.Other

local getcustomasset = getcustomasset
local fireclickdetector = fireclickdetector
local isfile = isfile

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
function vector.round(Vec)
    return vector.create(math.round(Vec.X), math.round(Vec.Y), math.round(Vec.Z))
end

TidalWave:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
end))

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function NotifyPoopSploit(Function)
    Notify({
        Title = 'Poop Sploit',
        Text = `Your executor doesn't support '{Function}'`,
        Type = 'Error',
        Duration = 5,
    })
end

local function GetMap()
    if ReplicatedStorage.CurrentMap:GetAttribute('MapLoaded') and ReplicatedStorage.CurrentMap.Value and ReplicatedStorage.CurrentMap.Value.Parent then
        return ReplicatedStorage.CurrentMap.Value
    end

    return nil
end

local function Run(f)
    f()
end

local function SafeRef(Obj, Path)
    return ObjectFunctions:SafeRef(Obj, Path)
end

local function IsBeast(Player)
    local IsBeast = SafeRef(Player or Plr, {"TempPlayerStatsModule", "IsBeast"})
    return IsBeast and IsBeast.Value or false
end

local function GetBeast()
    for _, Player in Players:GetPlayers() do
        if IsBeast(Player) then
            return Player
        end
    end
    return nil
end

local function GetFullName(Obj)
    return ObjectFunctions:GetFullName(Obj)
end

Run(function()
    function EntityLib:IsTeammate(Character)
        if TidalWave:IsFriend(Character.Player) then return true end
        local LocalIsBeast = SafeRef(Plr, {'TempPlayerStatsModule', 'IsBeast'})
        if LocalIsBeast and LocalIsBeast.Value then
            return false
        elseif LocalIsBeast and not LocalIsBeast.Value then
            local IsBeast = SafeRef(Character.Player, {'TempPlayerStatsModule', 'IsBeast'})
            return IsBeast and not IsBeast.Value
        end

        return false
    end

    function EntityLib:GetTeamColor(Character)
        local IsFriend, FriendColor = TidalWave:IsFriend(Character.Player)
        return (IsFriend and FriendColor) or (EntityLib:IsTeammate(Character) and Color3.fromRGB(0, 255, 0)) or Color3.fromRGB(255, 0, 0)
    end

    function EntityLib:GetUpdateConnections(Char)
        local Health = SafeRef(Char.Player, {'TempPlayerStatsModule', 'Health'})
        return {
            Health and Health:GetPropertyChangedSignal('Value') or nil
        }
    end
    
    function EntityLib:GetTeamUpdateConnections(Char)
        local IsBeast = SafeRef(Char.Player, {'TempPlayerStatsModule', 'Health'})
        return {
            IsBeast and IsBeast:GetPropertyChangedSignal('Value') or nil
        }
    end

    function EntityLib:GetCharacterProperties(Char)
        local Health = SafeRef(Char.Player, {'TempPlayerStatsModule', 'Health'})
        local IsBeast = SafeRef(Char.Player, {'TempPlayerStatsModule', 'Health'})
        return {
            Health = (IsBeast and IsBeast.Value and 100) or (Health and Health.Value) or 100,
            MaxHealth = 100
        }
    end

    EntityLib:Restart()
end)

Run(function() -- Combat
    Run(function() -- KillAura
        local KillAura, Range, WallCheck

        KillAura = Combat:CreateModule({
            Name = "KillAura",
            Enabled = function()
                repeat
                    local Character = EntityLib:GetClosestEntity({
                        Range = Range.Value,
                        WallCheck = WallCheck.Enabled
                    })
                    if Character then
                        local Hammer = EntityLib.Alive and EntityLib:FindFirstChild("Hammer")
                        local HammerEvent = Hammer and Hammer:FindFirstChild("HammerEvent")
                        if HammerEvent then
                            HammerEvent:FireServer("HammerHit", Character.Root)
                        end
                    end
                    task.wait(0.05)
                until not KillAura.Enabled
            end,
        })

        Range = KillAura:CreateSlider({
            Name = "Range",
            Default = 5,
            Min = 1,
            Max = 10
        })

        WallCheck = KillAura:CreateToggle({
            Name = "Wall Check",
            Default = true
        })
    end)

    Run(function() -- KillAuraOthers
        local KillAuraOthers, Range, WallCheck

        KillAuraOthers = Combat:CreateModule({
            Name = "KillAuraOthers",
            Enabled = function()
                repeat
                    local Beast = GetBeast()
                    local BeastChar = Beast and EntityLib:FindEntity(Beast)
                    if BeastChar then
                        local Character = EntityLib:GetClosestEntity({
                            Origin = BeastChar.Root.Position,
                            Range = Range.Value,
                            WallCheck = WallCheck.Enabled
                        })
                        if Character then
                            local Hammer = BeastChar.Character:FindFirstChild("Hammer")
                            local HammerEvent = Hammer and Hammer:FindFirstChild("HammerEvent")
                            if HammerEvent then
                                HammerEvent:FireServer("HammerHit", Character.Root)
                            end
                        end
                    end
                    task.wait(0.05)
                until not KillAuraOthers.Enabled
            end,
        })

        Range = KillAuraOthers:CreateSlider({
            Name = "Range",
            Default = 5,
            Min = 1,
            Max = 10
        })

        WallCheck = KillAuraOthers:CreateToggle({
            Name = "Wall Check",
            Default = true
        })
    end)
end)

Run(function() -- Player
    Run(function() -- BeastCrawl
        local BeastCrawl, DisableCrawl

        local ModifiedParts = {}

        BeastCrawl = PlayerCategory:CreateModule({
            Name = "BeastCrouch",
            Info = "Allows you to crouch as the beast",
            Function = function(Enabled)
                if Enabled then
                    repeat
                        DisableCrawl = SafeRef(Plr, {"TempPlayerStatsModule", "DisableCrawl"})
                        task.wait()
                    until DisableCrawl or not BeastCrawl.Enabled

                    if not BeastCrawl.Enabled then return end

                    DisableCrawl.Value = false
                    DisableCrawl:GetPropertyChangedSignal("Value"):Connect(function()
                        DisableCrawl.Value = false
                    end)

                    BeastCrawl:Clean(workspace.DescendantAdded:Connect(function(Child)
                        if Child:IsA("BasePart") and Child.CollisionGroup == 'VENT' and Child.CanCollide then
                            Child.CanCollide = false
                            ModifiedParts[Child] = true
                        end
                    end))

                    for _, Part in workspace:QueryDescendants("BasePart") do
                        if Part.CollisionGroup == 'VENT' and Part.CanCollide then
                            Part.CanCollide = false
                            ModifiedParts[Part] = true
                        end
                    end
                else
                    if DisableCrawl then
                        DisableCrawl.Value = IsBeast()
                    end
                    for Part in ModifiedParts do
                        Part.CanCollide = true
                    end
                    table.clear(ModifiedParts)
                    DisableCrawl = nil
                end
            end,
        })
    end)
end)

Run(function() -- Movement
    Run(function() -- BeastSlow
        local BeastSlow

        BeastSlow = Movement:CreateModule({
            Name = "BeastSlow",
            Info = "Makes the beast very slow",
            Enabled = function()
                local Cache
                while BeastSlow.Enabled do
                    if Cache and Cache.Parent then
                        Cache:FireServer("Jumped")
                    else
                        for _, v in EntityLib.List do
                            local PowersEvent = SafeRef(v.Character, {"BeastPowers", "PowersEvent"})
                            if PowersEvent then
                                PowersEvent:FireServer("Jumped")
                                Cache = PowersEvent
                                break
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end
        })
    end)
end)

Run(function() -- Visuals
    Run(function() -- ComputerESP
        local ComputerESP, OutlineTransparency, FillTransparency, Folder, ChildAdded, ChildRemoved
        local Highlights = {}

        local Red = BrickColor.Red()
        local ScreenColor = Color3.fromRGB(13, 105, 172)

        local function OnChildAdded(Child)
            if Child.Name ~= 'ComputerTable' then return end
            local TimeOut = os.clock() + 5
            local Screen
            local BillboardGui
            repeat
                Screen = Child:FindFirstChild("Screen")
                BillboardGui = Screen and Screen:FindFirstChild("BillboardGui")
                task.wait()
            until Screen and BillboardGui or not ComputerESP.Enabled or os.clock() >= TimeOut

            if Screen and BillboardGui and ComputerESP.Enabled then
                local Highlight = Instance.new("Highlight")
                Highlight.OutlineColor = Screen.BrickColor ~= Red and Screen.Color or ScreenColor
                Highlight.FillColor = Screen.BrickColor ~= Red and Screen.Color or ScreenColor
                Highlight.OutlineTransparency = OutlineTransparency.Value
                Highlight.FillTransparency = FillTransparency.Value
                Highlight.Adornee = Child
                Highlight.Parent = Folder
                
                Highlights[Child] = {
                    Connection = ComputerESP:Clean(Screen:GetPropertyChangedSignal("Color"):Connect(function()
                        Highlight.OutlineColor = Screen.BrickColor ~= Red and Screen.Color or ScreenColor
                        Highlight.FillColor = Screen.BrickColor ~= Red and Screen.Color or ScreenColor
                    end)),
                    Highlight = Highlight
                }
            end
        end

        local function OnChildRemoved(Child)
            if Highlights[Child] then
                Highlights[Child]:Destroy()
                Highlights[Child] = nil
            end
        end

        local function Disconnect()
            if ChildAdded then
                ChildAdded:Disconnect()
                ChildAdded = nil
            end
            if ChildRemoved then
                ChildRemoved:Disconnect()
                ChildRemoved = nil
            end
        end

        ComputerESP = Visuals:CreateModule({
            Name = "ComputerESP",
            Info = "Renders computers through walls.",
            Function = function(Enabled)
                if Enabled then
                    Folder = Instance.new("Folder")
                    Folder.Name = "ComputerChams"
                    Folder.Parent = TidalWave.Gui

                    ComputerESP:Clean(ReplicatedStorage.CurrentMap:GetPropertyChangedSignal("Value"):Connect(function()
                        Disconnect()
                        if ReplicatedStorage.CurrentMap.Value then
                            ChildAdded = ReplicatedStorage.CurrentMap.Value.ChildAdded:Connect(OnChildAdded)
                            ChildRemoved = ReplicatedStorage.CurrentMap.Value.ChildRemoved:Connect(OnChildRemoved)
                        end
                    end))

                    ComputerESP:Clean(workspace.DescendantAdded:Connect(OnChildAdded))
                    ComputerESP:Clean(workspace.DescendantRemoving:Connect(function(Child)
                        if Child.Name == 'ComputerTable' then
                            for i, v in Highlights do
                                if i == Child then
                                    v.Connection:Disconnect()
                                    v.Highlight:Destroy()
                                    Highlights[i] = nil
                                    break
                                end
                            end
                        end
                    end))
                    for _, v in workspace:QueryDescendants("Model#ComputerTable") do
                        task.spawn(OnChildAdded, v)
                    end
                else
                    if Folder then
                        Folder:Destroy()
                        Folder = nil
                    end
                    table.clear(Highlights)
                end
            end
        })

        OutlineTransparency = ComputerESP:CreateSlider({
            Name = "Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                if not ComputerESP.Enabled then return end
                for _, v in Folder:GetChildren() do
                    v.OutlineTransparency = Val
                end
            end
        })

        FillTransparency = ComputerESP:CreateSlider({
            Name = "Fill Transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                if not ComputerESP.Enabled then return end
                for _, v in Folder:GetChildren() do
                    v.FillTransparency = Val
                end
            end
        })
    end)
end)

Run(function() -- World
    Run(function() -- Click Ice Button
        World:CreateButton({
            Name = "Click Ice Button",
            Info = "Fires the ice button on abandoned facility maximus",
            Function = function()
                if not fireclickdetector then NotifyPoopSploit("fireclickdetector") return end
                local Map = GetMap()
                local Button = Map and Map:FindFirstChild("Button")
                local ClickDetector = Button and Button:FindFirstChildOfClass("ClickDetector")
                if ClickDetector then
                    fireclickdetector(ClickDetector)
                end
            end,
        })
    end)

    Run(function() -- InfiniteButtonRange
        World:CreateModule({
            Name = "InfiniteButtonRange",
            Info = "You can click ice button from very far away :D",
            Function = function(Enabled)
                local Map = GetMap()
                local Button = Map and Map:FindFirstChild("Button")
                local ClickDetector = Button and Button:FindFirstChildOfClass("ClickDetector")
                if ClickDetector then
                    ClickDetector.MaxActivationDistance = if Enabled then math.huge else 20
                end
            end,
        })
    end)
end)

Run(function() -- Other
    Run(function() -- CustomBeastMusic
        local CustomBeastMusic, Volume, MusicId, SoundObject, HeartbeatObject, RollOffMinDistance, RollOffMaxDistance, HeartbeatVolume

        local function SetId(Custom)
            if not SoundObject then return end

            if Custom then
                SoundObject.SoundId = Custom
                return
            end

            local Id
            if MusicId.Object.TextBox.Text:match("%.") then
                Id = getcustomasset(MusicId.Object.TextBox.Text)
            else
                local Match = MusicId.Object.TextBox.Text:match("%d+")
                if Match then
                    Id = "rbxassetid://" .. Match
                end
            end

            if Id then
                SoundObject.SoundId = Id
                SoundObject.RollOffMinDistance = RollOffMinDistance.Value
                SoundObject.RollOffMaxDistance = RollOffMaxDistance.Value
            end
        end

        local function OnCharacterAdded(Character)
            local Music = SafeRef(Character.Character, {"Hammer", "Handle", "SoundChaseMusic"})
            local Heartbeat = SafeRef(Character.Character, {"Hammer", "Handle", "SoundHeartBeat"})

            if not Music then
                local TimeOut = os.clock() + 5
                repeat
                    Music = SafeRef(Character.Character, {"Hammer", "Handle", "SoundChaseMusic"})
                    task.wait()
                until Music or not CustomBeastMusic.Enabled or os.clock() >= TimeOut
            end

            if not Heartbeat then
                local TimeOut = os.clock() + 5
                repeat
                    Heartbeat = SafeRef(Character.Character, {"Hammer", "Handle", "SoundHeartBeat"})
                    task.wait()
                until Heartbeat or not CustomBeastMusic.Enabled or os.clock() >= TimeOut
            end

            if Music and CustomBeastMusic.Enabled then
                Music = Music
                Music.Volume = Volume.Value
                SoundObject = Music
                SetId()
            end
            if Heartbeat and CustomBeastMusic.Enabled then
                Heartbeat.Volume = HeartbeatVolume.Value
                HeartbeatObject = Heartbeat
            end
        end

        CustomBeastMusic = Other:CreateModule({
            Name = "CustomBeastMusic",
            Info = "Allows you to change the beast music volume and set a custom ID.\nDefault beast music id is 1846863084.",
            Function = function(Enabled)
                if Enabled then
                    if Modules.TerrorRadius.Enabled then
                        Modules.TerrorRadius:Toggle(true)
                    end
                    for _, Character in EntityLib.List do
                        task.spawn(OnCharacterAdded, Character)
                    end
                    CustomBeastMusic:Clean(EntityLib.Events.EntityAdded:Connect(OnCharacterAdded))
                else
                    SetId("rbxassetid://1846863084")
                    SoundObject = nil
                    if HeartbeatObject then
                        HeartbeatObject.Volume = 1.9
                        HeartbeatObject = nil
                    end
                end
            end,
        })

        MusicId = CustomBeastMusic:CreateTextBox({
            Text = "rbxassetid://1846863084",
            Name = "Music Id",
            PlaceholderText = "[rbxassetid://1846863084]",
            Function = function()
                SetId()
            end
        })

        Volume = CustomBeastMusic:CreateSlider({
            Name = "Volume",
            Default = 0.4,
            Min = 0,
            Max = 10,
            Decimal = 100,
            Function = function(Val)
                if SoundObject then
                    SoundObject.Volume = Val
                end
            end
        })

        RollOffMinDistance = CustomBeastMusic:CreateSlider({
            Name = "Roll Off Min Distance",
            Default = 10,
            Min = 0,
            Max = 50,
            Function = function(Val)
                if SoundObject then
                    SoundObject.RollOffMinDistance = Val
                end
            end
        })

        RollOffMaxDistance = CustomBeastMusic:CreateSlider({
            Name = "Roll Off Max Distance",
            Default = 30,
            Min = 0,
            Max = 100,
            Function = function(Val)
                if SoundObject then
                    SoundObject.RollOffMaxDistance = Val
                end
            end
        })

        HeartbeatVolume = CustomBeastMusic:CreateSlider({
            Name = "Heartbeat Volume",
            Default = 1.9,
            Min = 0,
            Max = 10,
            Decimal = 100,
            Function = function(Val)
                if HeartbeatObject then
                    HeartbeatObject.Volume = Val
                end
            end
        })
    end)

    Run(function() -- TerrorRadius
        local TerrorRadius, Volume, Layer1Distance, Layer2Distance, Layer3Distance, ChaseDistance, Music, CurrentlyPlaying

        local Layer1, Layer2, Layer3, Chase
        local LookAwayThread, WalkAwayThread, StartChaseThread

        local SupportedFileTypes = {'mp3', 'ogg', 'wav', 'flac'}
        local RequiredFiles = {'Layer 1', 'Layer 2', 'Layer 3', 'Chase'}

        local function GetBeast()
            for _, Char in EntityLib.List do
                if Char.Character:FindFirstChild("Hammer") then
                    return Char.Player
                end
            end

            return nil
        end

        local function GetAssets()
            local Tab = {}

            for i, v in RequiredFiles do
                local Any = false
                for _, v2 in SupportedFileTypes do
                    if isfile(`TidalWave/Assets/{v}.{v2}`) then
                        Tab[i] = getcustomasset(`{v}.{v2}`)
                        Any = true
                        break
                    end
                end
                if not Any then
                    Notify({Text = `Missing file`, Duration = 5, Type = "Error"})
                    return nil
                end
            end

            if #Tab < 4 then
                local Missing = {}
                for i = 1, 4 do
                    if Tab[i] == nil then
                        table.insert(Missing, RequiredFiles[i] .. ".mp3")
                    end
                end

                Notify({
                    Text = `Failed to find required sounds for TerrorRadius.\nMissing files: {table.concat(Missing, ", ")}`,
                    Duration = 10,
                    Type = 'Error'
                })

                return nil
            end

            return table.unpack(Tab)
        end
        
        local Tweens = {}

        local function Tween(Object, Info, Goal)
            if Tweens[Object] then
                Tweens[Object]:Cancel()
                Tweens[Object] = nil
            end

            local NewTween = TweenService:Create(Object, Info, Goal)
            NewTween:Play()
            Tweens[Object] = NewTween
            NewTween.Completed:Once(function(Status)
                if Status == Enum.PlaybackState.Completed then
                    Tweens[Object] = nil
                end
            end)

            return NewTween
        end

        local function CancelLookAwayThread()
            if LookAwayThread then
                task.cancel(LookAwayThread)
                LookAwayThread = nil
            end
        end

        local function CancelWalkAwayThread()
            if WalkAwayThread then
                task.cancel(WalkAwayThread)
                WalkAwayThread = nil
            end
        end

        local function CancelStartChaseThread()
            if StartChaseThread then
                task.cancel(StartChaseThread)
                StartChaseThread = nil
            end
        end

        local function CancelAllThreads()
            CancelLookAwayThread()
            CancelWalkAwayThread()
            CancelStartChaseThread()
        end

        TerrorRadius = Other:CreateModule({
            Name = 'TerrorRadius',
            Info = 'Allows you to have a custom terror radius\nYou must have 4 sound files in the TidalWave/Assets folder for this to work: "Layer 1.mp3", "Layer 2.mp3", "Layer 3.mp3", "Chase.mp3"\nSupports mp3, ogg, wav and flac files',
            Function = function(Enabled)
                if Enabled then
                    if not getcustomasset then NotifyPoopSploit("getcustomasset") return end
                    local Layer1Asset, Layer2Asset, Layer3Asset, ChaseAsset = GetAssets()

                    if not Layer1Asset then return end
                    Layer1, Layer2, Layer3, Chase = Instance.new('Sound'), Instance.new('Sound'), Instance.new('Sound'), Instance.new('Sound')

                    Layer1.SoundId, Layer2.SoundId, Layer3.SoundId, Chase.SoundId = Layer1Asset, Layer2Asset, Layer3Asset, ChaseAsset

                    Layer1.Volume, Layer2.Volume, Layer3.Volume, Chase.Volume = Volume.Value, Volume.Value, Volume.Value, Volume.Value
                    Layer1.Looped, Layer2.Looped, Layer3.Looped, Chase.Looped = true, true, true, true
                    Layer1.Parent, Layer2.Parent, Layer3.Parent, Chase.Parent = workspace, workspace, workspace, workspace

                    if TidalWave.Modules.CustomBeastMusic.Enabled then
                        TidalWave.Modules.CustomBeastMusic:Toggle(true)
                    end

                    local function PlaySound(Sound, FadeTime)
                        if Sound.Playing then return end

                        local Info = TweenInfo.new(FadeTime, Enum.EasingStyle.Linear)
                        if CurrentlyPlaying then
                            local Tween = Tween(CurrentlyPlaying, Info, {Volume = 0})
                            local Copy = CurrentlyPlaying
                            Tween.Completed:Once(function(State)
                                if State == Enum.PlaybackState.Completed then
                                    Copy:Stop()
                                end
                            end)
                        end

                        CurrentlyPlaying = Sound
                        Sound:Play()
                        Tween(Sound, Info, {Volume = Volume.Value})
                    end

                    local function StopCurrentSound(FadeTime)
                        if CurrentlyPlaying then
                            local Info = TweenInfo.new(FadeTime, Enum.EasingStyle.Linear)
                            local Tween = Tween(CurrentlyPlaying, Info, {Volume = 0})
                            local Copy = CurrentlyPlaying
                            Tween.Completed:Once(function(State)
                                if State == Enum.PlaybackState.Completed then
                                    Copy:Stop()
                                end
                            end)

                            CurrentlyPlaying = nil
                        end
                    end

                    local Chasing = false

                    while TerrorRadius.Enable do
                        if not EntityLib.Alive then task.wait() continue end
                        
                        local Beast = GetBeast()
                        
                        if Beast then
                            local Ent = EntityLib:FindEntity(Beast)
                            if Ent then
                                Music = SafeRef(Ent.Character, {'Hammer', 'Handle', 'SoundChaseMusic'})
                                if Music then
                                    Music.Volume = 0
                                end

                                local Magnitude = vector.magnitude(Ent.Root.Position - EntityLib.Root.Position)
                                local BeastLookDirection = Ent.Head.CFrame.LookVector * vector.hort
                                local RequiredDirection = vector.normalize((EntityLib.Head.Position - Ent.Head.Position) * vector.hort)
                                local Dot = vector.dot(BeastLookDirection, RequiredDirection)
                                local Angle = math.deg(math.acos(Dot))
                                
                                if Ent.Humanoid.MoveDirection ~= vector.zero and EntityLib.Humanoid.MoveDirection ~= vector.zero and Angle <= 60 and not EntityLib:WallCheck(EntityLib.Head.Position, Ent.Head.Position) then
                                    if StartChaseThread then task.wait() continue end

                                    StartChaseThread = task.delay(0.5, function()
                                        Magnitude = vector.magnitude(Ent.Root.Position - EntityLib.Root.Position)
                                        BeastLookDirection = Ent.Head.CFrame.LookVector * vector.hort
                                        RequiredDirection = vector.normalize((EntityLib.Head.Position - Ent.Head.Position) * vector.hort)
                                        Dot = vector.dot(BeastLookDirection, RequiredDirection)
                                        Angle = math.deg(math.acos(Dot))
                                        StartChaseThread = nil

                                        if Ent.Humanoid.MoveDirection ~= vector.zero and EntityLib.Humanoid.MoveDirection ~= vector.zero and Angle <= 60 and not EntityLib:WallCheck(EntityLib.Head.Position, Ent.Head.Position) then
                                            Chasing = true
                                            CancelAllThreads()
                                            PlaySound(Chase, 0.5)
                                        end
                                    end)
                                elseif Chasing then
                                    if Magnitude <= ChaseDistance.Value then
                                        CancelWalkAwayThread()
                                        if LookAwayThread then task.wait() continue end

                                        LookAwayThread = task.delay(10, function()
                                            LookAwayThread = nil
                                            Chasing = false
                                            CancelAllThreads()
                                            PlaySound(Layer3, 0.5)
                                        end)
                                    else
                                        if WalkAwayThread then task.wait() continue end

                                        WalkAwayThread = task.delay(3, function()
                                            WalkAwayThread = nil
                                            Chasing = false
                                            CancelAllThreads()
                                            PlaySound(Layer3, 0.5)
                                        end)
                                    end
                                else
                                    CancelAllThreads()
                                    Chasing = false
                                    if Magnitude <= Layer3Distance.Value then
                                        PlaySound(Layer3, 0.5)
                                    elseif Magnitude <= Layer2Distance.Value then
                                        PlaySound(Layer2, 0.5)
                                    elseif Magnitude <= Layer1Distance.Value then
                                        PlaySound(Layer1, 0.5)
                                    else
                                        StopCurrentSound(0.5)
                                    end
                                end
                            else
                                StopCurrentSound(0.5)
                                CancelAllThreads()
                            end
                        else
                            StopCurrentSound(0.5)
                            CancelAllThreads()
                        end

                        task.wait()
                    end
                else
                    CancelAllThreads()
                    if Music then
                        Music.Volume = 0.4
                        Music = nil
                    end
                    for _, v in {Layer1, Layer2, Layer3, Chase} do
                        v:Stop()
                        v:Destroy()
                    end
                    Layer1, Layer2, Layer3, Chase, CurrentlyPlaying = nil, nil, nil, nil, nil
                end
            end,
        })

        Volume = TerrorRadius:CreateSlider({
            Name = 'Volume',
            Default = 0.4,
            Min = 0,
            Max = 10,
            Decimal = 100,
            Function = function(Val)
                if CurrentlyPlaying then
                    CurrentlyPlaying.Volume = Val
                end
            end
        })

        Layer1Distance = TerrorRadius:CreateSlider({
            Name = 'Layer 1 Distance',
            Default = 40,
            Min = 20,
            Max = 60,
            Decimal = 10,
        })

        Layer2Distance = TerrorRadius:CreateSlider({
            Name = 'Layer 2 Distance',
            Default = 30,
            Min = 15,
            Max = 50,
            Decimal = 10,
        })

        Layer3Distance = TerrorRadius:CreateSlider({
            Name = 'Layer 3 Distance',
            Default = 20,
            Min = 10,
            Max = 40,
            Decimal = 10,
        })

        ChaseDistance = TerrorRadius:CreateSlider({
            Name = 'Chase Distance',
            Default = 10,
            Min = 0,
            Max = 20,
            Decimal = 10,
        })
    end)
end)