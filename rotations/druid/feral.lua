dark_addon.druid = { }
local D = dark_addon.druid


local function buffs()
    local spells = {}
    local back2bear = false

    --if player.combat and -buff("Enrage") and player.buff("Bear Form").up and target.health.percent > 95 then
    --    cast("Enrage", player)
    --    return true
    --end

    --TODO: check that enough mana for all spells before committing.
    if -buff("Mark of the Wild") or -buff("Thorns") and player.power.mana.percent >= 25 then
        if player.buff("Bear Form").up then
            back2bear = true
            table.insert(spells, {spell="Bear Form", target="player", is_done=dont_have_buff})
        end
        if -buff("Mark of the Wild") then
            table.insert(spells, {spell="Mark of the Wild", target="player", is_done=have_buff})
        end
        if -buff("Thorns") then
            table.insert(spells, {spell="Thorns", target="player", is_done=have_buff})
        end
        if back2bear then
            table.insert(spells, {spell="Bear Form", target="player", is_done=have_buff})
        end
        startsequence({spells = spells})
        return true
    end
end
dark_addon.environment.hook(buffs)

local function status()
    local msg = ""
    local nenemies = enemies.around(5)
    local x, y, z = UnitPosition('player')
    x = x * 10; x = math.floor(x); x = x / 10
    y = y * 10; y = math.floor(y); y = y / 10
    z = z * 10; z = math.floor(z); z = z / 10
    msg = msg .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z)
    msg = msg .. " M:" .. math.floor(player.power.mana.percent) .. " "
    if dark_addon.environment.hooks.sequenceactive() then
        msg = msg .. "SequenceActive "
    end
    if target.exists then
        msg = msg .. "TTD:" .. target.time_to_die .. " "
    end
    msg = msg .. "E:"..tostring(nenemies).." D:"..tostring(target.distance)
    dark_addon.interface.status_extra(msg)
end

local function combat_balance()
    if target.castable("Moonfire") and target.debuff("Moonfire").down then return cast("Moonfire") end
    if target.castable("Wrath") then return cast("Wrath") end
end
dark_addon.environment.hook(combat_balance)

local function combat_bear()
    if player.castable("Enrage") and target.health.percent >= 95 then
        cast("Enrage")
        return true
    end
    if target.debuff("Growl").down and target.castable("Growl") and group.num > 1 and not UnitIsUnit("targettarget", "player") then
        cast("Growl")
        return true
    end
    if enemies.around(5) > 1 and target.castable("Swipe") then
        return cast("Swipe")
    end
    --log(target.castable("Demoralizing Roar"), target.debuff("Demoralizing Roar").down)
    if target.castable("Demoralizing Roar") and target.debuff("Demoralizing Roar").down then return cast("Demoralizing Roar") end
    --log(target.castable("Maul"), target.time_to_die > 3)
    if target.castable("Maul") and target.time_to_die > 3 then return cast("Maul") end
end
dark_addon.environment.hook(combat_bear)


local function combat()
    if D.heal and D.heal() then return end
    if D.group_heal and D.group_heal() then return end
    if buffs() then return end
    if not target.exists or not target.enemy or not target.alive then return end
    if not damage_toggle:GetChecked() then return end
    auto_attack()
    if player.buff('Bear Form').up then
        return combat_bear()
    else
        return combat_balance()
    end
end

local function resting()
    if player.dead then return end
    if D.heal and D.heal() then return end
    if D.group_heal and D.group_heal() then return end
    if buffs() then return end

    --if player.buff("Barkskin").down and -spell("Barkskin") == 0 then return cast("Barkskin") end

    if player.buff('Bear Form').down then
        if target.exists and target.enemy and target.alive and target.castable("Moonfire") then
            log("opener: moonfire")
            return cast("Moonfire")
        end
    else
        if target.exists and target.enemy and target.alive and target.distance < 5 then
            auto_attack()
            if group.num > 1 then
                if target.castable("Growl") then
                    log("opener: GROWL")
                    return cast("Growl")
                end
            else
                if target.castable("Demoralizing Roar") then
                    log("opened: Demoralizing Roar")
                    return cast("Demoralizing Roar")
                end
            end
        end
    end

end

dark_addon.rotation.register({
    name = 'eferal',
    label = 'euler feral',
    combat = combat,
    resting = resting,
    status = status,
})
