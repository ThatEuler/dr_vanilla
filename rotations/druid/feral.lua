
local function heal()
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
end
dark_addon.environment.hook(heal)

local function buffs()
    local spells = {}
    local back2bear = false

    if player.combat and -buff("Enrage") and player.buff("Bear Form").up and target.health.percent > 95 then
        cast("Enrage", player)
        return true
    end

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
    local nenemies = enemies.count(function(unit)
        return true
    end)
    msg = msg .. "M:" .. math.floor(player.power.mana.percent) .. " "
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
    if target.castable("Demoralizing Roar") and target.debuff("Demoralizing Roar").down then return cast("Demoralizing Roar") end
    if target.time_to_die > 3 and target.castable("Maul") then return cast("Maul") end
end
dark_addon.environment.hook(combat_bear)


local function combat()
    if heal() then return end
    --if buffs() then return end
    if not target.exists or not target.enemy or not target.alive then return end
    auto_attack()
    if player.buff('Bear Form').up then
        return combat_bear()
    else
        return combat_balance()
    end
end

local function resting()
    if player.dead then return end
    --if heal() then return end
    --if buffs() then return end

    --if player.buff("Barkskin").down and -spell("Barkskin") == 0 then return cast("Barkskin") end

    if player.buff('Bear Form').down then
        if target.exists and target.enemy and target.alive and target.castable("Moonfire") then return cast("Moonfire") end
    end
    --local time, value = GetSpellCooldown2("Enrage")
    --local clip = dark_addon.settings.fetch('_engine_castclip', 0)
    --local cd = time + value - GetTime() - clip
    --if cd < 0 then cd = 0 end
    --log(GetSpellCooldown2("Enrage"))
    --log(cd, GetTime())
end

dark_addon.rotation.register({
    name = 'eferal',
    label = 'euler feral',
    combat = combat,
    resting = resting,
    status = status,
})
