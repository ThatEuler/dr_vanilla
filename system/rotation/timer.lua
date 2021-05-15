
dark_addon.rotation.timer = {
    lag = 0
}

local last_loading = GetTime()
local loading_wait = math.random(120, 300)
  
local function tick()
    --log("tick")

    --if IsMounted() then return end
    if not master_toggle:GetChecked() then
        dark_addon.interface.status('Ready...')
        return
    end

    if SetLastHardwareAction then SetLastHardwareAction(0) end

    if dark_addon.rotation.active_rotation then

        if dark_addon.rotation.active_rotation.status then
            dark_addon.rotation.active_rotation.status()
        end

        cd = GetActionCooldown(61)
        if cd ~= 0 then
            --log("gcd")
            if dark_addon.rotation.active_rotation.gcd then
                dark_addon.rotation.active_rotation.gcd()
            end
        --elseif CastingSpellID() ~= 0 then
        --    log("wait for spell cast")
        elseif dark_addon.fishing.enabled then
            --log("fishing")
            dark_addon.fishing.fish()
        elseif dark_addon.environment.hooks.sequenceactive() then
            --log("sequence")
            dark_addon.environment.hooks.dosequence()
        elseif UnitAffectingCombat('player') then
            --log("combat")
            if dark_addon.rotation.active_rotation.combat then
                dark_addon.rotation.active_rotation.combat()
            end
        else
            --log("rest")
            if dark_addon.rotation.active_rotation.resting then
                dark_addon.rotation.active_rotation.resting()
            end
            --log(GetTime() - last_loading, loading_wait)
            if GetTime() - last_loading > loading_wait then
                dark_addon.interface.status(
                  dark_addon.interface.loading_messages[math.random(table.getn(dark_addon.interface.loading_messages))],
                  10
                )
                last_loading = GetTime()
                loading_wait = math.random(120, 300)
            else
                dark_addon.interface.status('Resting...')
            end
        end
    else
        dark_addon.interface.status('Load a rotation...')        
    end
end

dark_addon.on_ready(function()
    dark_addon.rotation.timer.ticker = C_Timer.NewTicker(0.1, tick)
end)
  