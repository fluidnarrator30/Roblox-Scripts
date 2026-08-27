local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local Players: Players = GetService('Players')
local UIS: UserInputService = GetService('UserInputService')

local TidalWave = shared.TidalWave
local Libraries = TidalWave.Libraries
local Signal = Libraries.Signal
local Whitelist = Libraries.Whitelist

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local EntityLib = {
    Alive = false,
    Running = false,
    List = {},
    Connections = {},
    LocalConnections = {},
    PlayerConnections = {},
    CharacterThreads = {},
    Events = setmetatable({}, {
        __index = function(self, i)
            self[i] = Signal.new()
            return self[i]
        end
    })
}

local function LoopClean(Tab)
    for _, v in Tab do
        if typeof(v) == 'table' then
            LoopClean(v)
        elseif typeof(v) == 'RBXScriptConnection' then
            v:Disconnect()
        elseif typeof(v) == 'thread' then
            pcall(task.cancel, v)
        end
    end
    table.clear(Tab)
end

function EntityLib:WaitForChild(Obj, Name, TimeOut, Property)
    local Object = if Property then Obj[Name] else Obj:FindFirstChildOfClass(Name)
    if Object then
        return Object
    end

    if Property then
        TimeOut = os.clock() + (TimeOut or 9e9)
        repeat
            task.wait()
            
            local Prop = Obj[Name]
            if Prop then
                return Prop
            end
        until os.clock() >= TimeOut

        return nil
    else
        if EntityLib.Connections[Obj] then return end

        local Thread = coroutine.running()

        local Con, DelayThread

        local function Disconnect()
            if Con then
                Con:Disconnect()
                Con = nil
            end
            if DelayThread then
                task.cancel(DelayThread)
                DelayThread = nil
            end
            if EntityLib.Connections and EntityLib.Connections[Obj] then
                EntityLib.Connections[Obj] = nil
            end
        end

        EntityLib.Connections[Obj] = {
            Disconnect = function()
                Disconnect()
                coroutine.resume(Thread, nil)
            end
        }

        Con = Obj.ChildAdded:Connect(function(Child)
            if Child:IsA(Name) then
                Disconnect()
                coroutine.resume(Thread, Child)
            end
        end)

        if TimeOut then
            DelayThread = task.delay(TimeOut, function()
                DelayThread = nil
                Disconnect()
                coroutine.resume(Thread, nil)
            end)
        end

        return coroutine.yield()
    end
end

function EntityLib:IsTeammate(Entity)
    if Entity.NPC then return false end
    if TidalWave:IsFriend(Entity.Player) then return true end
    if not Plr.Team then return false end
    if not Entity.Player.Team then return false end

    return Entity.Player.Team == Plr.Team
end

function EntityLib:FindEntity(Character)
    for i, Entity in EntityLib.List do
        if Entity.Character == Character or Entity.Player == Character then
            return Entity, i
        end
    end

    return nil
end

function EntityLib:FindNPC(Character)
    for i, Entity in EntityLib.List do
        if Entity.Player then continue end
        if Entity.Character == Character then
            return Entity, i
        end
    end

    return nil
end

function EntityLib:FindPlayer(Character)
    for i, Entity in EntityLib.List do
        if Entity.NPC then continue end
        if Entity.Character == Character or Entity.Player == Character then
            return Entity, i
        end
    end

    return nil
end

function EntityLib:GetTeamUpdateConnections(Entity)
    return {}
end

function EntityLib:GetCharacterProperties(Entity)
    return {
        Health = Entity and Entity.Humanoid.Health or 0,
        MaxHealth = Entity and Entity.Humanoid.MaxHealth or 0
    }
end

function EntityLib:GetUpdateConnections(Entity)
    return {
        Entity.Humanoid:GetPropertyChangedSignal('Health'),
        Entity.Humanoid:GetPropertyChangedSignal('MaxHealth')
    }
end

function EntityLib:CanAttack(Entity)
    if Entity.Player and not select(2, Whitelist:Get(Entity.Player)) then
        return false
    end

    return Entity.Health > 0 and Entity.Character:FindFirstChildOfClass('ForceField') == nil
end

function EntityLib:GetTeamColor(Entity)
    local Player = Entity and Entity.Player or nil
    if TidalWave.Menus.Friends.Options.UseFriends.Enabled then
        local FriendColor = TidalWave:GetFriendColor(Player)
        if FriendColor then
            return FriendColor
        end
    end

    if TidalWave.Menus.Config.Options.UseTeamColor.Enabled then
        local TeamColor = Player and Player.Team and Player.TeamColor
        if TeamColor and tostring(TeamColor) ~= 'White' then
            return TeamColor.Color
        end
    end

    return nil
end

local Params = RaycastParams.new()
Params.RespectCanCollide = true

function EntityLib:WallCheck(Origin, Target)
    local IgnoreList = {EntityLib.Character}
    for _, Entity in EntityLib.List do
        table.insert(IgnoreList, Entity.Character)
    end

    Params.FilterDescendantsInstances = IgnoreList

	return workspace.Raycast(workspace, Origin, (Target - Origin), Params)
end

local function InsertCharacter(Entity, Part, Range, MouseLocation, Table)
    local Vector, OnScreen = Camera:WorldToViewportPoint(Part.Position)
    if OnScreen then
        local Magnitude = (MouseLocation - Vector2.new(Vector.X, Vector.Y)).Magnitude
        if Magnitude <= Range then
            table.insert(Table, {
                Entity = Entity,
                Magnitude = Magnitude,
                Part = Part,
                Vector = Vector
            })
        end
    end
end

function EntityLib:GetClosestEntityWithinMouse(Settings)
	if EntityLib.Alive then
		local MouseLocation = Settings.MouseOrigin or UIS.GetMouseLocation(UIS)
        local WithinMouse = {}
        local Part = Settings.Part or 'Root'
        local Range = Settings.Range or math.huge
        local Origin = Settings.Origin or Camera.CFrame

		for _, Entity in EntityLib.List do
            if Entity.Player and not Settings.Players then continue end
            if Entity.NPC and not Settings.NPCs then continue end
            if Entity.Teammate then continue end
            if not EntityLib:CanAttack(Entity) then continue end

            if Part == 'Closest' then
                local Limbs = {}
                for _, Limb in Entity.Character:GetChildren() do
                    if Limb:IsA('BasePart') then
                        InsertCharacter(Entity, Limb, Range, MouseLocation, Limbs)
                    end
                end

                table.sort(Limbs, function(a, b)
                    return a.Magnitude < b.Magnitude
                end)

                if Limbs[1] then
                    table.insert(WithinMouse, Limbs[1])
                end
            else
                InsertCharacter(Entity, Entity[Part], Range, MouseLocation, WithinMouse)
            end
		end

		table.sort(WithinMouse, Settings.Sort or function(a, b)
			return a.Magnitude < b.Magnitude
		end)

		for _, Tab in WithinMouse do
			if Settings.WallCheck and EntityLib:WallCheck(Origin, Tab.Entity[Part].Position) then continue end
			return Tab.Entity, Tab.Vector
		end
	end

    return nil
end

function EntityLib:GetClosestEntity(Settings)
	if EntityLib.Alive then
		local RootPosition = Settings.Origin or EntityLib.Root.Position
        local ClosestEntities = {}
        local Part = Settings.Part or 'Root'
        local Range = Settings.Range or math.huge
        local Sort = Settings.Sort or function(a, b)
			return a.Magnitude < b.Magnitude
		end

		for _, Entity in EntityLib.List do
			if Entity.Player and not Settings.Players then continue end
            if Entity.NPC and not Settings.NPCs then continue end
            if Entity.Teammate then continue end
            if not EntityLib:CanAttack(Entity) then continue end

            local Magnitude = vector.magnitude(Entity[Part].Position - RootPosition)
			if Magnitude <= Range then
                table.insert(ClosestEntities, {
                    Entity = Entity,
                    Magnitude = Magnitude
                })
			end
		end

		table.sort(ClosestEntities, Sort)

		for _, Tab in ClosestEntities do
			if Settings.WallCheck and EntityLib:WallCheck(RootPosition, Tab.Entity[Part].Position) then continue end
			return Tab.Entity
		end
	end

    return nil
end

function EntityLib:GetClosestEntities(Settings)
	local Characters = {}

	if EntityLib.Alive then
		local ClosestEntities = {}
        local Origin = Settings.Origin or EntityLib.Root.Position
        local Part = Settings.Part or 'Root'
        local Range = Settings.Range or math.huge
        local Limit = Settings.Limit or math.huge
        local Sort = Settings.Sort or function(a, b)
			return a.Magnitude < b.Magnitude
		end

		for _, Entity in EntityLib.List do
			if Entity.Player and not Settings.Players then continue end
            if Entity.NPC and not Settings.NPCs then continue end
            if Entity.Teammate then continue end
            if not EntityLib:CanAttack(Entity) then continue end

			local Magnitude = vector.magnitude(Entity[Part].Position - Origin)
			if Magnitude <= Range then
                table.insert(ClosestEntities, {
                    Entity = Entity,
                    Magnitude = Magnitude
                })
			end
		end

		table.sort(ClosestEntities, Sort)

        local Returned = 0

		for _, Tab in ClosestEntities do
			if Settings.WallCheck and EntityLib:WallCheck(Origin, Tab.Entity[Part].Position) then continue end
            table.insert(Characters, Tab.Entity)
            Returned += 1
			if Returned >= Limit then break end
		end
	end

	return Characters
end

local LocalCharacterPropertyBlacklist = {
    NPC = true,
    Player = true,
    Connections = true,
}

function EntityLib:AddEntity(Char, Player)
    if not Char then return end
    EntityLib.CharacterThreads[Char] = task.spawn(function()
        local Humanoid = EntityLib:WaitForChild(Char, 'Humanoid', 10)
        local Root = Humanoid and EntityLib:WaitForChild(Humanoid, 'RootPart', workspace.StreamingEnabled and 9e9 or 10, true)
        local Head = Char:WaitForChild('Head', 10) or Root

        if Root and Humanoid then
            local Entity = {
                Player = Player,
                NPC = Player == nil,
                Character = Char,
                Humanoid = Humanoid,
                Animator = Humanoid:FindFirstChildOfClass('Animator') or Humanoid,
                Root = Root,
                Head = Head,
                HipHeight = Humanoid.HipHeight + (Root.Size.Y / 2) + (Humanoid.RigType == Enum.HumanoidRigType.R6 and 2 or 0),
                RigType = Humanoid.RigType,
                Connections = {}
            }
            
            if Humanoid.RigType == Enum.HumanoidRigType.R15 then
                Entity.UpperTorso = Char:FindFirstChild('UpperTorso')
                Entity.LowerTorso = Char:FindFirstChild('LowerTorso')
            else
                Entity.Torso = Char:FindFirstChild('Torso')
            end
            
            for i, v in EntityLib:GetCharacterProperties(Entity) do
                Entity[i] = v
            end

            local ConnectionsTable = Player == Plr and EntityLib.LocalConnections or Entity.Connections

            for _, v in EntityLib:GetUpdateConnections(Entity) do
                table.insert(ConnectionsTable, v:Connect(function()
                    for Property, Value in EntityLib:GetCharacterProperties(Entity) do
                        Entity[Property] = Value
                        if LocalCharacterPropertyBlacklist[Property] then return end
                        EntityLib[Property] = Value
                    end
                end))
            end
            for _, v in EntityLib:GetTeamUpdateConnections(Entity) do
                table.insert(ConnectionsTable, v:Connect(function()
                    if Player == Plr then
                        EntityLib:Refresh()
                    else
                        EntityLib:RefreshEntity(Entity.Character, Player)
                    end
                end))
            end

            if Player == Plr then
                for i, v in Entity do
                    if LocalCharacterPropertyBlacklist[i] then continue end
                    EntityLib[i] = v
                end
                EntityLib.Alive = true
                EntityLib.Events.LocalAdded:Fire(Entity)
            else
                Entity.Teammate = EntityLib:IsTeammate(Entity)
                table.insert(EntityLib.List, Entity)
                EntityLib.Events.EntityAdded:Fire(Entity)
            end
        end
        EntityLib.CharacterThreads[Char] = nil
    end)
end

local LocalItems = {'Character', 'Humanoid', 'Animator', 'Root', 'Head', 'Torso', 'UpperTorso', 'LowerTorso', 'HipHeight', 'RigType'}

function EntityLib:RemoveEntity(Char, Player)
    if not Char then return end
    local Character, Index = EntityLib:FindEntity(Char)

    if Player == Plr then
        for _, v in LocalItems do
            EntityLib[v] = nil
        end
        for Property in EntityLib:GetCharacterProperties() do
            EntityLib[Property] = nil
        end
        for _, v in EntityLib.LocalConnections do
            v:Disconnect()
        end
        table.clear(EntityLib.LocalConnections)
        EntityLib.Alive = false
        EntityLib.Events.LocalRemoved:Fire(EntityLib)
    elseif Character then
        local Thread = EntityLib.CharacterThreads[Char]
        if Thread then
            task.cancel(Thread)
            EntityLib.CharacterThreads[Char] = nil
        end
        LoopClean(Character.Connections)
        table.remove(EntityLib.List, Index)
        EntityLib.Events.EntityRemoved:Fire(Character)
    end
end

function EntityLib:RefreshEntity(Char, Player)
    EntityLib:RemoveEntity(Char, Player)
    EntityLib:AddEntity(Char, Player)
end

function EntityLib:AddPlayer(Player)
    if Player.Character then
        EntityLib:RemoveEntity(Player.Character, Player)
        EntityLib:AddEntity(Player.Character, Player)
    end

    EntityLib.PlayerConnections[Player] = {
        Player.CharacterAdded:Connect(function(Char)
            EntityLib:RefreshEntity(Char, Player)
        end),
        Player.CharacterRemoving:Connect(function(Char)
            EntityLib:RemoveEntity(Char, Player)
        end),
        Player:GetPropertyChangedSignal('Team'):Connect(function()
            if Player == Plr then
                EntityLib:Refresh()
            else
                EntityLib:RefreshEntity(Player.Character, Player)
            end
        end)
    }
end

function EntityLib:RemovePlayer(Player)
    local PlayerConnections = EntityLib.PlayerConnections[Player]
    if PlayerConnections then
        for _, v in PlayerConnections do
            v:Disconnect()
        end
        table.clear(PlayerConnections)
        EntityLib.PlayerConnections[Player] = nil
    end
    EntityLib:RemoveEntity(Player)
end

function EntityLib:Start()
    if EntityLib.Running then
        EntityLib:Stop()
    end

    table.insert(EntityLib.Connections, Players.PlayerAdded:Connect(function(Player)
        EntityLib:AddPlayer(Player)
    end))

    table.insert(EntityLib.Connections, Players.PlayerRemoving:Connect(function(Player)
        EntityLib:RemovePlayer(Player)
    end))

    table.insert(EntityLib.Connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
    end))

    for _, Player in Players:GetPlayers() do
        EntityLib:AddPlayer(Player)
    end

    EntityLib.Running = true
end

function EntityLib:Stop()
    for _, v in EntityLib.Connections do
        v:Disconnect()
    end
    table.clear(EntityLib.Connections)
    for _, v in EntityLib.PlayerConnections do
        for _, v2 in v do
            v2:Disconnect()
        end
        table.clear(v)
    end
    table.clear(EntityLib.PlayerConnections)
    for _, Player in Players:GetPlayers() do
        EntityLib:RemovePlayer(Player)
    end
    for _, Entity in EntityLib.List do
        EntityLib:RemoveEntity(Entity)
    end
    EntityLib.Running = false
end

function EntityLib:Shutdown()
    if EntityLib.Running then
        EntityLib:Stop()
    end
    for _, v in EntityLib.Events do
        v:DisconnectAll()
    end
    table.clear(EntityLib.Events)
    EntityLib.Events = nil
    LoopClean(EntityLib)
    EntityLib = nil
end

function EntityLib:Refresh()
    local List = table.clone(EntityLib.List)
    for _, Entity in List do
        EntityLib:RefreshEntity(Entity.Character, Entity.Player)
    end
end

function EntityLib:Restart()
    EntityLib:Stop()
    EntityLib:Start()
end

EntityLib:Start()

return EntityLib