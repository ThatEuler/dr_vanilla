
dark_addon.rotation.timer = {
    lag = 0
  }
  
local function tick()

    --if IsMounted() then return end
    if not master_toggle:GetChecked() then
        dark_addon.interface.status('Ready...')
        return
    end

    if dark_addon.rotation.active_rotation then

        cd = GetActionCooldown(61)
        if cd ~= 0 then
            if dark_addon.rotation.active_rotation.gcd then
                dark_addon.rotation.active_rotation.gcd()
            end
            return
        end
    
        if UnitAffectingCombat('player') then
            if dark_addon.rotation.active_rotation.combat then
                dark_addon.rotation.active_rotation.combat()
            end
        else
            if dark_addon.rotation.active_rotation.resting then
                dark_addon.rotation.active_rotation.resting()
            end
        end
    else
        dark_addon.interface.status('Load a rotation...')        
    end
end

dark_addon.on_ready(function()
    dark_addon.rotation.timer.ticker = C_Timer.NewTicker(0.1, tick)
end)
  