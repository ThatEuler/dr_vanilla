
local enemies = {}
local enemies_cache = {}

local function enemies_count(func)
    local count = 0
    for _, unit in pairs(enemies_cache) do
        if func(unit) then
            count = count + 1
        end
    end
    return count
end

function enemies:count(func)
    return enemies_count
end

local function enemies_match(func)
    for _, unit in pairs(enemies_cache) do
        if func(unit) then
            return unit
        end
    end
    return false
end

function enemies:match(func)
    return enemies_match
end

local function enemies_around(distance)
    return enemies_count(function (unit)
        return unit.alive
        and (
            (distance and unit.distance <= distance)
            or not distance
        )
    end)
end

function enemies:around(distance)
    return enemies_around
end

function dark_addon.environment.conditions.enemies()
    return setmetatable({ }, {
        __index = function(t, k)
            return enemies[k](t)
        end
    })
end

local function add_enemy(guid)
    --log("addenemy", guid, UnitName(guid), UnitTarget(guid), UnitReaction("player", guid))
    -- TODO: it would be better to add neutral enemy units only after they aggro a team member.
    -- Maybe add UnitThreatSituation??
    if not enemies_cache[guid] and UnitReaction("player", guid) <= 4 then
        enemies_cache[guid] = dark_addon.environment.conditions.unit(guid)
    end
end

local function remove_enemy(guid)
    if enemies_cache[guid] then
        enemies_cache[guid] = nil
    end
end

C_Timer.NewTicker(0.5, function()
    local guids = GetUnits()
    enemies_cache = {}
    for _, guid in guids do
        add_enemy(guid)
    end    
end)