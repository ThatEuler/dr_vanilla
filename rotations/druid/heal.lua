local D = dark_addon.druid

local CurseCD = 0

local function heal()
    if not healing_toggle:GetChecked() then return false end
    if player.buff("Cat Form").up or player.buff("Bear Form").up then return false end

    local spells = {}
    local back2bear = false

    -- save up for Rejuv
    if player.health.percent < 75 and player.buff("Rejuvenation").down and not castable("Rejuvenation") then
        log("save for Rejuv")
        return true
    end

---[[
    -- regrowth
    if player.health.percent < 50 and -buff("Regrowth") then
        if player.buff("Bear Form").up then
            back2bear = true
            table.insert(spells, {spell="Bear Form", target="player", is_done=dont_have_buff})
        end
        table.insert(spells, {spell="Regrowth", target="player", is_done=have_buff})
        if back2bear then
            table.insert(spells, {spell="Bear Form", target="player", is_done=have_buff})
        end
        startsequence({spells = spells})
        log("regrowth seq")
        return true
    end
--]]

---[[
    -- rejuv
    if player.health.percent < 75 and -buff("Rejuvenation") then
        if player.buff("Bear Form").up then
            back2bear = true
            table.insert(spells, {spell="Bear Form", target="player", is_done=dont_have_buff})
        end
        table.insert(spells, {spell="Rejuvenation", target="player", is_done=have_buff})
        if back2bear then
            table.insert(spells, {spell="Bear Form", target="player", is_done=have_buff})
        end
        startsequence({spells = spells})
        log("rejuv seq")
        return true
    end
--]]

---[[
    -- Healing Touch
    if player.health.percent < 33 and player.castable("Healing Touch") then
        if player.buff("Bear Form").up then
            back2bear = true
            table.insert(spells, {spell="Bear Form", target="player", is_done=dont_have_buff})
        end
        table.insert(spells, {spell="Healing Touch", target="player"})
        if back2bear then
            table.insert(spells, {spell="Bear Form", target="player", is_done=have_buff})
        end
        log("healing touch seq")
        startsequence({spells = spells})
        return true
    end
--]]


    local dispellable_unit
    dispellable_unit = player.removable("curse")
    if dispellable_unit and castable("Remove Curse") and IsSpellInRange("Remove Curse", dispellable_unit.unitID) == 1 and (GetTime() > CurseCD) then
        print('Cure Poison on ', dispellable_unit.name)
        cast("Remove Curse", dispellable_unit)
        CurseCD = GetTime() + 0.5
        return true
    end

end
dark_addon.environment.hook(heal)
D.heal = heal

local function do_hot(spellname, should_cast)
    -- if not enough mana for hot then bail
    log("start do_hot. spellname", spellname)
    if not castable(spellname) then
        log("not castable.")
        return false
    end

    -- if any group member is the target of a mob, keep rejuv up on them.
    local hot_candidate = group.match(function (member)
        -- member if a dr unit.  so you can do member.name etc
        if not should_cast(member) then
            log("should not cast", spellname, "on group member", member.name, "yet")
            return nil
        end
        local combat_enemy = enemies.match(function (e)
            log("check enemy", e.name, "whose target is", e.target)
            if e.combat and e.target == member.guid then
                return e
            end
        end)
        if combat_enemy then
            log("group member", member.name, "is being targeted by", combat_enemy.name)
            return member
        end
        log(member.name, "doesn't need to be buffed with", spellname)
    end)

    if hot_candidate then
        log("group member", hot_candidate.name, "needs", spellname)
        cast(spellname, hot_candidate)
        return true
    end
end
dark_addon.environment.hook(do_hot)

local function should_rejuv(u)
    if u.distance > 40 then log(u.name, "is out of Rejuv range") end
    return u.buff("Rejuvenation").down and u.health.percent < 95 and u.distance < 40 and u.castable("Rejuvenation")
end
dark_addon.environment.hook(should_rejuv)

local function should_regrowth(u)
    if u.distance > 40 then log(u.name, "is out of Regrowth range") end
    return u.buff("Regrowth").down and u.health.percent < 66 and u.distance < 40 and u.castable("Regrowth")
end
dark_addon.environment.hook(should_regrowth)


local function group_heal()
    if not healing_toggle:GetChecked() then return end
    if player.buff("Cat Form").up or player.buff("Bear Form").up then return false end
    if group.num < 2 then return end
    --log("group_heal", "lowest is:", lowest.name, "combat?", group.combat)

    if do_hot("Rejuvenation", should_rejuv) then return true end
    if do_hot("Regrowth", should_regrowth) then return true end
    if lowest and lowest.health.percent < 50 and lowest.castable("Healing Touch") then
        cast("Healing Touch", lowest)
        return true
    end

    local dispellable_unit
    dispellable_unit = group.removable("curse")
    if dispellable_unit and castable("Remove Curse") and IsSpellInRange("Remove Curse", dispellable_unit.unitID) == 1 and (GetTime() > PoisonCD) then
        print('Cure Poison on ', dispellable_unit.name)
        cast("Remove Curse", dispellable_unit)
        PoisonCD = GetTime() + 0.5
        return true
    end
end
dark_addon.environment.hook(group_heal)
D.group_heal = group_heal




