
local current_sequence = nil

-- helper functions

function dont_have_buff(spell)
    return player.buff(spell).down
end
dark_addon.environment.hook(dont_have_buff)

function have_buff(spell)
    return player.buff(spell).up
end
dark_addon.environment.hook(have_buff)

-- core sequence code

local function reset()
    current_sequence.complete = true
    current_sequence.active = false
    current_sequence.copy = nil
end

function dark_addon.environment.hooks.sequenceactive()
    return current_sequence and current_sequence.active
end

function dark_addon.environment.hooks.startsequence(sequence)
    if not dark_addon.protected then return end
    if sequence.complete then log("new sequence is already complete?!?"); return true end
    current_sequence = sequence
    if not current_sequence.active then current_sequence.active = true end
    if not current_sequence.copy then
        log("makeing sequence copy")
        current_sequence.copy = { }
        for _, value in ipairs(current_sequence.spells) do
            table.insert(current_sequence.copy, value)
        end
    end
end

function dark_addon.environment.hooks.dosequence()
    if player.dead then reset(); return end

    local currcast = current_sequence.copy[1]
    log("currcast is", currcast.spell)
    if tonumber(currcast.spell) then
        currcast.spell = GetSpellInfo(currcast.spell)
    end
    local is_done = false
    if not currcast.is_done then is_done = (currcast.casttime ~= nil)
    else is_done = currcast.is_done(currcast.spell) end
    log("is_done", is_done, "casttime", currcast.casttime, "delta", (GetTime()-(currcast.casttime or 0)))
    if not is_done then
        if not currcast.casttime or (GetTime() - currcast.casttime) > 0.5 then
            log("casting", currcast.spell, "on", currcast.target, "at", GetTime())
            _CastSpellByName(currcast.spell, currcast.target)
            currcast.casttime = GetTime()
        end
    else
        log("step is good. move on to the next step.")
        currcast.casttime = nil
        table.remove(current_sequence.copy, 1)
        if table.getn(current_sequence.copy) == 0 then
            reset()
        end
    end
end
dark_addon.environment.hook(dark_addon.environment.hooks.dosequence)

