
local players = {}
local players_cache = {}

local function players_count(func)
    local count = 0
    for _, unit in pairs(players_cache) do
        if func(unit) then
            count = count + 1
        end
    end
    return count
end

function players:count(func)
    return players_count
end

local function players_match(func)
    for _, unit in pairs(players_cache) do
        if func(unit) then
            return unit
        end
    end
    return false
end

function players:match(func)
    return players_match
end

local function players_around(distance)
    return players_count(function (unit)
        return unit.alive
        and (
            (distance and unit.distance <= distance)
            or not distance
        )
    end)
end

function players:around(distance)
    return players_around
end

function dark_addon.environment.conditions.players()
    return setmetatable({ }, {
        __index = function(t, k)
            return players[k](t)
        end
    })
end

local function add_player(guid)
    players_cache[guid] = dark_addon.environment.conditions.unit(guid)
end

local function remove_player(guid)
    if players_cache[guid] then
        players_cache[guid] = nil
    end
end

C_Timer.NewTicker(0.5, function()
    local guids = GetPlayers()
    --chat("there are "..table.getn(guids).." players")
    players_cache = {}
    for _, guid in guids do
        --chat(UnitName(guid))
        add_player(guid)
    end    
end)