local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local Players: Players = GetService('Players')

local Plr = Players.LocalPlayer

local Methods = {}

local function FindSpecificObj(Obj, Index, Method, Compare)
    local Found = 0
    for _, v in Obj[Method](Obj) do
        if Compare(v) then
            Found += 1
            if Found == Index then
                return v
            end
        end
    end
    return nil
end

function Methods:FindSpecificChild(Obj, Name, Index)
    return FindSpecificObj(Obj, Index, 'GetChildren', function(Obj)
        return Obj.Name == Name
    end)
end

function Methods:FindSpecificChildOfClass(Obj, Class, Index)
    return FindSpecificObj(Obj, Index, 'GetChildren', function(Obj)
        return Obj.ClassName == Class
    end)
end

function Methods:FindSpecificChildWhichIsA(Obj, Class, Index)
    return FindSpecificObj(Obj, Index, 'GetChildren', function(Obj)
        return Obj:IsA(Class)
    end)
end

function Methods:FindSpecificDescendant(Obj, Name, Index)
    return FindSpecificObj(Obj, Index, 'GetChildren', function(Obj)
        return Obj.Name == Name
    end)
end

function Methods:FindSpecificDescendantOfClass(Obj, Class, Index)
    return FindSpecificObj(Obj, Index, 'GetChildren', function(Obj)
        return Obj.ClassName == Class
    end)
end

function Methods:FindSpecificDescendantWhichIsA(Obj, Class, Index)
    return FindSpecificObj(Obj, Index, 'GetChildren', function(Obj)
        return Obj:IsA(Class)
    end)
end

function Methods:FindFirstDescendant(Obj, Name)
    return Methods:FindSpecificDescendant(Obj, Name, 1)
end

function Methods:FindFirstDescendantOfClass(Obj, Class)
    return Methods:FindSpecificDescendantOfClass(Obj, Class, 1)
end

function Methods:FindFirstDescendantWhichIsA(Obj, Class)
    return Methods:FindSpecificDescendantWhichIsA(Obj, Class, 1)
end

local function WaitForChildFunction(Obj, TimeOut, GetMethod, AddedMethod, AddedFunction)
    for _, v in Obj[GetMethod](Obj) do
        if AddedFunction(v) then
            return v
        end
    end

    local Thread = coroutine.running()
    local DelayThread

    local Con; Con = Obj[AddedMethod]:Connect(function(Child)
        if AddedFunction(Child) then
            Con:Disconnect()
            if DelayThread then
                task.cancel(DelayThread)
                DelayThread = nil
            end
            coroutine.resume(Thread, Child)
        end
    end)

    if TimeOut then
        DelayThread = task.delay(TimeOut, function()
            Con:Disconnect()
            DelayThread = nil
            coroutine.resume(Thread, nil)
        end)
    end

    return coroutine.yield()
end

function Methods:WaitForSpecificChild(Obj, Name, Index, TimeOut)
    local ExistingObj = FindSpecificObj(Obj, Index, 'GetChildren', function(Obj) return Obj.Name == Name end)
    if ExistingObj then return ExistingObj end
    return WaitForChildFunction(Obj, TimeOut, 'GetChildren', 'ChildAdded', function()
        local SpecificChild = FindSpecificObj(Obj, Index, 'GetChildren', function(Obj) return Obj.Name == Name end)
        return SpecificChild ~= nil
    end)
end

function Methods:WaitForSpecificChildOfClass(Obj, Class, Index, TimeOut)
    local ExistingObj = FindSpecificObj(Obj, Index, 'GetChildren', function(Obj) return Obj.ClassName == Class end)
    if ExistingObj then return ExistingObj end
    return WaitForChildFunction(Obj, TimeOut, 'GetChildren', 'ChildAdded', function()
        return FindSpecificObj(Obj, Index, 'GetChildren', function(Obj) return Obj.ClassNamee == Class end) ~= nil
    end)
end

function Methods:WaitForSpecificChildWhichIsA(Obj, Class, Index, TimeOut)
    local ExistingObj = FindSpecificObj(Obj, Index, 'GetChildren', function(Obj) return Obj:IsA(Class) end)
    if ExistingObj then return ExistingObj end
    return WaitForChildFunction(Obj, TimeOut, 'GetChildren', 'ChildAdded', function()
        return FindSpecificObj(Obj, Index, 'GetChildren', function(Obj) return Obj:IsA(Class) end) ~= nil
    end)
end

function Methods:WaitForSpecificDescendant(Obj, Name, Index, TimeOut)
    local ExistingObj = FindSpecificObj(Obj, Index, 'GetDescendants', function(Obj) return Obj.Name == Name end)
    if ExistingObj then return ExistingObj end
    return WaitForChildFunction(Obj, TimeOut, 'GetDescendants', 'DescendantAdded', function()
        return FindSpecificObj(Obj, Index, 'GetDescendants', function(Obj) return Obj.Name == Name end) ~= nil
    end)
end

function Methods:WaitForSpecificDescendantOfClass(Obj, Class, Index, TimeOut)
    local ExistingObj = FindSpecificObj(Obj, Index, 'GetDescendants', function(Obj) return Obj.ClassName == Class end)
    if ExistingObj then return ExistingObj end
    return WaitForChildFunction(Obj, TimeOut, 'GetDescendants', 'DescendantAdded', function()
        return FindSpecificObj(Obj, Index, 'GetDescendants', function(Obj) return Obj.ClassNamee == Class end) ~= nil
    end)
end

function Methods:WaitForSpecificDescendantWhichIsA(Obj, Class, Index, TimeOut)
    local ExistingObj = FindSpecificObj(Obj, Index, 'GetDescendants', function(Obj) return Obj:IsA(Class) end)
    if ExistingObj then return ExistingObj end
    return WaitForChildFunction(Obj, TimeOut, 'GetDescendants', 'DescendantAdded', function()
        return FindSpecificObj(Obj, Index, 'GetDescendants', function(Obj) return Obj:IsA(Class) end) ~= nil
    end)
end

function Methods:WaitForChildOfClass(Obj, Class, TimeOut)
    local ExistingObj = Obj:FindFirstChildOfClass(Class)
    if ExistingObj then return ExistingObj end
    return WaitForChildFunction(Obj, TimeOut, 'GetChildren', 'ChildAdded', function(Child)
        return Child.ClassName == Class
    end)
end

function Methods:WaitForChildWhichIsA(Obj, Class, TimeOut)
    local ExistingObj = Obj:FindFirstChildWhichIsA(Class)
    if ExistingObj then return ExistingObj end
    return WaitForChildFunction(Obj, TimeOut, 'GetChildren', 'ChildAdded', function(Child)
        return Obj:IsA(Class)
    end)
end

function Methods:WaitForDescendant(Obj, Name, TimeOut)
    return Methods:WaitForSpecificDescendant(Obj, Name, 1, TimeOut)
end

function Methods:WaitForDescendantOfClass(Obj, Class, TimeOut)
    return Methods:WaitForSpecificDescendantOfClass(Obj, Class, 1, TimeOut)
end

function Methods:WaitForDescendantWhichIsA(Obj, Class, TimeOut)
    return Methods:WaitForSpecificDescendantWhichIsA(Obj, Class, 1, TimeOut)
end

function Methods:FindFirstChildOfClassWithName(Obj, Class, Name)
    return FindSpecificObj(Obj, 1, 'GetChildren', function(Obj)
        return Obj.ClassName == Class and Obj.Name == Name
    end)
end

function Methods:FindFirstChildWhichIsAWithName(Obj, Class, Name)
    return FindSpecificObj(Obj, 1, 'GetChildren', function(Obj)
        return Obj:IsA(Class) and Obj.Name == Name
    end)
end

local Keywords = {
	['nil'] = true,
	['for'] = true,
	['do'] = true,
	['while'] = true,
	['true'] = true,
	['false'] = true,
	['repeat'] = true,
	['until'] = true,
	['and'] = true,
	['or'] = true,
	['not'] = true,
	['local'] = true,
	['function'] = true,
	['if'] = true,
	['then'] = true,
	['return'] = true,
	['end'] = true,
	['break'] = true,
	['continue'] = true,
	['else'] = true,
	['elseif'] = true,
	['in'] = true,
	['self'] = true,
}

function Methods:GetFullName(Obj)
    if typeof(Obj) ~= 'Instance' then return nil end
    if Obj == game then return 'game' end
    if Obj.Parent == nil then return nil end

    local Parts = {}
    local Characters = {}
    
    for _, Player in Players:GetPlayers() do
        if Player.Character then
            Characters[Player.Character] = Player == Plr and {Name = 'LocalPlayer'} or Player
        end
    end

    while Obj.Parent ~= game do
        local Name
        if Obj == Plr then
            Name = '.LocalPlayer'
        elseif Obj.ClassName == 'Model' and Characters[Obj] then
            local Length = #Parts
            Parts[Length + 1] = {Name = '.Character'}
            Parts[Length + 2] = {Name = `.{Characters[Obj].Name}`}
            Obj = Players
            break
        else
            Name = Obj.Name:match('^[%a_][%w_]*$') and not Keywords[Obj.Name] and `.{Obj.Name}` or `['{Obj.Name}']`
        end

        Parts[#Parts + 1] = {
            Name = Name,
            DebugId = Obj.Parent[Obj.Name] ~= Obj and Obj:GetDebugId() or nil
        }

        Obj = Obj.Parent
    end
    
    local FullName = Obj == workspace and 'workspace' or `game:GetService('{Obj.ClassName}')`

    for i = #Parts, 1, -1 do
        local Part = Parts[i]
        if Part.DebugId then
            FullName = `(function(Obj, Id)\n\tfor _, v in Obj:GetChildren() do\n\t\tif v:GetDebugId() == Id then\n\t\t\treturn v\n\t\tend\n\tend\nend)({FullName}, '{Part.DebugId}' --[[{Part.Name:sub(2)}]])`
        else
            FullName ..= Part.Name
        end
    end

    return FullName
end

function Methods:SafeRef(Obj, Path)
    if not Obj then return nil end
    
    for _, v in Path do
        local NewObj = Obj:FindFirstChild(v)
        if NewObj then
            Obj = NewObj
        else
            return nil
        end
    end

    return Obj
end

return Methods