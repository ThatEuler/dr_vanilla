local buff = { }

function buff:exists()
  for i = 1, 20 do
    local icon = UnitBuff(self.unitID, i)
    if dark_addon.icon_match(icon, self.spell) then return true end
  end
end

function buff:down()
  return not self.exists
end

function buff:up()
  return self.exists
end

function buff:any()
  local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
  if buff then
    return true
  end
  return false
end

function buff:count()
  local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
  if buff and (caster == 'player' or caster == 'pet') then
    return count
  end
  return 0
end

function buff:remains()
  local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
  if buff and (caster == 'player' or caster == 'pet') then
    return expires - GetTime()
  end
  return 0
end

function buff:duration()
  local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
  if buff and (caster == 'player' or caster == 'pet') then
    return duration
  end
  return 0
end

function buff:stealable()
  local buff, count, duration, expires, caster, stealable = UnitBuff(self.unitID, self.spell, 'any')
  if stealable then
    return true
  end
  return false
end

local function canbuff(spell)
  return player.buff(spell).down and player.castable(spell)
end
dark_addon.environment.hook(canbuff)

function dark_addon.environment.conditions.buff(unit)
  return setmetatable({
    unitID = unit.unitID
  }, {
    __index = function(self, func)
      --log("index self", self.unitID, "func", func)
      local result = buff[func](self)
      dark_addon.console.debug(6, 'buff', 'green', self.unitID .. '.buff(' .. tostring(self.spell) .. ').' .. func .. ' = ' .. dark_addon.format(result))
      return result
    end,
    __call = function(self, arg)
      if type(arg) == 'table' then
        self.spell = arg.name
      elseif tonumber(arg) then
        self.spell = GetSpellInfo(arg)
      else
        self.spell = arg
      end
      return self
    end,
    __unm = function(t)
      --log("canbuff(", t.unitID, t.spell, ")")
      local result = canbuff(t.spell)
      dark_addon.console.debug(6, 'buff', 'green', t.unitID .. '.buff(' .. tostring(t.spell) .. ').exists = ' .. dark_addon.format(result))
      return result
    end
  })
end
