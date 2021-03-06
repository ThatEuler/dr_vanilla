
dark_addon.environment.virtual = {
    targets = {},
    resolvers = {},
    resolved = {},
}

local function GroupType()
    return GetNumRaidMembers() > 0 and 'raid' or GetNumPartyMembers() > 0 and 'party' or 'solo'
end

function dark_addon.environment.virtual.validate(virtualID)
    if dark_addon.environment.virtual.targets[virtualID] or virtualID == 'group' or virtualID == 'players' then
        return true
    end
    return false
end

function dark_addon.environment.virtual.resolve(virtualID)
    if virtualID == 'group' then
        return 'group', 'group'
    elseif virtualID == 'players' then
        return 'players', 'players'
    else
        return dark_addon.environment.virtual.resolved[virtualID], 'unit'
    end
end

function dark_addon.environment.virtual.targets.lowest()
    local members = GetNumGroupMembers()
    local group_type = GroupType()
    if dark_addon.environment.virtual.resolvers[group_type] then
        return dark_addon.environment.virtual.resolvers[group_type](members)
    end
end

function dark_addon.environment.virtual.resolvers.unit(unitA, unitB)
    local healthA = UnitHealth(unitA) / UnitHealthMax(unitA) * 100
    local healthB = UnitHealth(unitB) / UnitHealthMax(unitB) * 100
    --log("compare", unitA, unitB, "health", healthA, healthB)
    if healthA < healthB then
        return unitA, healthA
    else
        return unitB, healthB
    end
end

function dark_addon.environment.virtual.resolvers.party(members)
    local lowest = 'player'
    local lowest_health
    for i = 1, (members - 1) do
        local unit = 'party' .. i
        if not UnitCanAttack('player', unit) and UnitInRange(unit) and not UnitIsDeadOrGhost(unit) then
            if not lowest then
                lowest, lowest_health = dark_addon.environment.virtual.resolvers.unit(unit, 'player')
            else
                lowest, lowest_health = dark_addon.environment.virtual.resolvers.unit(unit, lowest)
            end
        end
    end
    return lowest
end

function dark_addon.environment.virtual.resolvers.raid(members)
    local lowest = 'player'
    local lowest_health
    for i = 1, members do
        local unit = 'raid' .. i
        if not UnitCanAttack('player', unit) and UnitInRange(unit) and not UnitIsDeadOrGhost(unit) then
        if not lowest then
            lowest, lowest_health = unit, UnitHealth(unit)
        else
            lowest, lowest_health = dark_addon.environment.virtual.resolvers.unit(unit, lowest)
        end
        end
    end
    return lowest
end

function dark_addon.environment.virtual.targets.raid_group_lowest()
    local members = GetNumRaidMembers()
    local lowest = 'player'
    local lowest_health
    local player_group
    for i = 1, members do
        local unit = 'raid' .. i
        if UnitIsUnit(unit, 'player') then
        _, _, player_group = GetRaidRosterInfo(i)
        break
        end
    end
    if player_group == nil then
        return lowest
    end
    --print('player is in group ', player_group)
    for i = 1, members do
        local unit = 'raid' .. i
        local group
        _, _, group = GetRaidRosterInfo(i)
        if not UnitCanAttack('player', unit) and UnitInRange(unit) and not UnitIsDeadOrGhost(unit) and group == player_group then
        if not lowest then
            lowest, lowest_health = unit, UnitHealth(unit)
        else
            lowest, lowest_health = dark_addon.environment.virtual.resolvers.unit(unit, lowest)
        end
        end
    end
    return lowest
end

function dark_addon.environment.virtual.resolvers.solo()
    return 'player'
end

function dark_addon.environment.virtual.targets.tank()
    local members = GetNumPartyMembers()
    local group_type = GroupType()
    if dark_addon.environment.virtual.resolvers[group_type..'_tank'] then
        return dark_addon.environment.virtual.resolvers[group_type..'_tank'](members)
    end
end

function dark_addon.environment.virtual.resolvers.party_tank(members)
    local tank = 'player'
    for i = 1, (members - 1) do
        local unit = 'party' .. i
        if UnitHealthMax(unit) > UnitHealthMax(tank) then
        tank = unit
        end
    end
    return tank
end

function dark_addon.environment.virtual.resolvers.raid_tank(members)
    local tank = 'player'
    for i = 1, (members - 1) do
        local unit = 'raid' .. i
        if UnitHealthMax(unit) > UnitHealthMax(tank) then
        tank = unit
        end
    end
    return tank
end

function dark_addon.environment.virtual.resolvers.solo_tank()
    return 'player'
end

dark_addon.on_ready(function()
    C_Timer.NewTicker(0.1, function()
        for target, callback in pairs(dark_addon.environment.virtual.targets) do
            dark_addon.environment.virtual.resolved[target] = callback()
        end
    end)
end)
