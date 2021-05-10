
local InCombat, AutoAttackEnabled

function _CastSpellByName(spell, target)
    if target == 'player' then
        CastSpellByName(spell, target)
        dark_addon.console.debug(4, 'cast', 'red', spell .. ' on player')
    else
        CastSpellByName(spell)
        dark_addon.console.debug(4, 'cast', 'red', spell)
    end
    dark_addon.interface.status(spell)
end

function _CastGroundSpellByName(spell, target)
    local target = target or "target"
    RunMacroText("/cast [@cursor] " .. spell)
    dark_addon.console.debug(4, 'cast', 'red', spell .. ' on ' .. target)
    dark_addon.interface.status(spell)
end

function _CastSpellByID(spell, target)
    if tonumber(spell) then
        spell, _ = GetSpellInfo(spell)
    end
    return _CastSpellByName(spell, target)
end

function _CastGroundSpellByID(spell, target)
    if tonumber(spell) then
        spell, _ = GetSpellInfo(spell)
    end
    return _CastGroundSpellByName(spell, target)
end

function _SpellStopCasting()
    SpellStopCasting()
end

local function auto_attack()
    if InCombat and not AutoAttackEnabled then
        CastSpellByName('Attack')
    end
end

local function auto_shot()
    if not IsCurrentSpell(75) then
        CastSpellByID(75)
    end
end

local function auto_shoot()
    if not IsCurrentSpell(5019) then
        CastSpellByID(5019)
    end
end

function _RunMacroText(text)
    RunMacroText(text)
    dark_addon.console.debug(4, 'macro', 'red', text)
    dark_addon.interface.status('Macro')
end

local turbo = false

function dark_addon.environment.hooks.cast(spell, target)
    turbo = dark_addon.settings.fetch('_engine_turbo', false)
    if type(target) == 'table' then target = target.unitID end
    if type(spell) == 'table' then spell = spell.namerank end
    if type(spell) == 'number' then spell = GetSpellName(spell) end
    if target ~= nil and not UnitCanAttack('player', target) and enablehcd and UnitName(target) ~= nil then
        dark_addon.savedHealTarget = target
        if tonumber(spell) then spell, _ = GetSpellInfo(spell) end
        dark_addon.console.debug(1, 'engine', 'engine', string.format('casting spell %s on %s. UnitHealth %d', spell, UnitName(target), UnitHealth(target)))
    end
    if  (turbo or not IsCasting()) then
        if target == 'ground' then
        if tonumber(spell) then
            _CastGroundSpellByID(spell, target)

        end
        else
        if tonumber(spell) then
            _CastSpellByID(spell, target)
        else
            _CastSpellByName(spell, target)
        end
        end
    end

end

function dark_addon.environment.hooks.auto_attack()
    auto_attack()
end

function dark_addon.environment.hooks.auto_shot()
    auto_shot()
end

function dark_addon.environment.hooks.auto_shoot()
    auto_shoot()
end

function dark_addon.environment.hooks.stopcast()
    _SpellStopCasting()
end

function dark_addon.environment.hooks.macro(text)
    _RunMacroText(text)
end

dark_addon.event.register("PLAYER_ENTER_COMBAT", function() AutoAttackEnabled = true end)
dark_addon.event.register("PLAYER_LEAVE_COMBAT", function() AutoAttackEnabled = false end)
dark_addon.event.register("PLAYER_REGEN_DISABLED", function() InCombat = true end)
dark_addon.event.register("PLAYER_REGEN_ENABLED", function() InCombat = false end)