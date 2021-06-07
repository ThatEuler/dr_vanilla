local D = dark_addon.druid

local tfcd = 0

local function combat_cat()

    if castable("Tiger's Fury") and player.buff("Tiger's Fury").down and tfcd < GetTime() then
        cast("Tiger's Fury")
        tfcd = GetTime() + 5
        return true
    end

    if castable("Rake") and target.buff("Rake").down then
        cast("Rake")
        return true
    end

    if GetComboPoints() < 5 and target.time_to_die > 3 then
        if target.castable("Claw") then cast("Claw"); return true end
    else
        if target.castable("Rip") then cast("Rip"); return true end
    end

end
dark_addon.environment.hook(combat_cat)
D.combat_cat = combat_cat

