
--local UnitReverseDebuff = dark_addon.environment.unit_reverse_debuff

local group = { }


function group:num()
    return GetNumGroupMembers()
end

local function group_count(func)
    local count = 0
    for unit in dark_addon.environment.iterator() do
        if not func or func(unit) then 
            count = count + 1
        end
    end
    return count
end

function group:count(func)
    return group_count
end

local function group_match(func)
    for unit in dark_addon.environment.iterator() do
        if func(unit) then 
            return unit
        end
    end
    return nil
end

function group:match(func)
    return group_match
end

local function group_buffable(spell)
    return group_match(function (unit)
        return unit.alive and unit.buff(spell).down
    end)
end

function group:buffable(spell)
    return group_buffable
end

local function check_removable(removable_type)
    return group_match(function (unit)
        local debuff, count, duration, expires, caster, found_debuff = UnitReverseDebuff(unit.unitID, dark_addon.data.removables[removable_type])
        return debuff and (count == 0 or count >= found_debuff.count) and unit.health.percent <= found_debuff.health
    end)
end

local function group_removable(...)
    for i = 1, arg.n do
        local removable_type = arg[i]
        if dark_addon.data.removables[removable_type] then
            local possible_unit = check_removable(removable_type)
            if possible_unit then
                return possible_unit
            end
        end
    end
    return false
end

function group:removable(...)
    return group_removable
end

local function group_dispellable(spell)
    return group_match(function (unit)
        return disp:CanDispelWith(unit.unitID, spell)
    end)
end

function group:dispellable(spell)
    return group_dispellable
end

function group_under(...)
    local percent, distance, effective = arg
    return group_count(function (unit)
        return unit.alive
            and (
                (distance and unit.distance <= distance)
                or not distance
            )
            and (
                (effective and unit.health.effective < percent) 
                or (not effective and unit.health.percent < percent)
            )
    end)
end

function group:under(...)
    return group_under
end

function group:combat()
    -- true if anyone in the group is in combat
    local member_in_combat = group_match(function(unit)
        if UnitAffectingCombat(unit.unitID) then
            return true
        end
    end)
    return member_in_combat ~= nil
end

function dark_addon.environment.conditions.group()
    return setmetatable({ }, {
        __index = function(t, k)
            return group[k](t)
        end
    })
end
