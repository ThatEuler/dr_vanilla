
local function heal()
    -- save up for Rejuv
    if player.health.percent < 75 and player.buff("Rejuvenation").down then
        if not castable("Rejuvenation") then return true
        else cast("Rejuvenation"); return true end
    end

    -- save up for Healing Touch
    if player.health.percent < 33 then
        if not castable("Healing Touch") then return true 
        else cast("Healing Touch"); return true end
    end
end
dark_addon.environment.hook(heal)


local function buffs()
    if -spell("Mark of the Wild") == 0 and player.buff("Mark of the Wild").down then return cast("Mark of the Wild", "player") end
    if player.buff("Thorns").down then return cast("Thorns", "player") end
end
dark_addon.environment.hook(buffs)


local function combat()
    if heal() then return end
    if not target.exists or not target.enemy or not target.alive then return end
    auto_attack()
    if buffs() then return end
    if target.castable("Moonfire") and target.debuff("Moonfire").down then return cast("Moonfire") end
    if target.castable("Wrath") then return cast("Wrath") end
end

local function resting()
    if player.dead then return end
    if heal() then return end
    if buffs() then return end

    --if player.buff("Barkskin").down and -spell("Barkskin") == 0 then return cast("Barkskin") end

    if target.exists and target.enemy and target.alive and target.castable("Wrath") then return cast("Wrath") end
end

local function gcd()
    --log("gcd...")
end

local function interface()
    --log('interface')
end


dark_addon.rotation.register({
    name = 'eferal',
    label = 'euler feral',
    combat = combat,
    resting = resting,
    gcd = gcd,
    interface = interface,
})
