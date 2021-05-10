
dark_addon.console = {
    debugLevel = 0,
    file = '',
    line = '',
    logfile = nil,
}

function join(arg)
    msg = tostring(arg[1])
    for i = 2, arg.n do
        msg = msg .. " " .. tostring(arg[i])
    end
    return msg
end

function dark_addon.console.set_level(level)
    level = tonumber(level) or 0
    dark_addon.console.debugLevel = level
    dark_addon.settings.store('debug_level', level)
end

function dark_addon.console.toggle(level)
end

function dark_addon.console.log(msg)
    L(msg)
end
  
function dark_addon.console.notice(...)
    dark_addon.console.log(date('%H:%M:%S', time())..'|cff91FF00[notice]|r ' .. join(arg))
end
  
function dark_addon.console.debug(level, section, color, ...)
    if dark_addon.console.debugLevel >= level then
        L("["..section.. "] " .. join(arg))
    end
end

function dark_addon.log(...)
    log('|cff' .. dark_addon.color .. '['..dark_addon.name..']|r ' .. join(arg))
end

function dark_addon.error(string)
    log('|cff' .. dark_addon.color .. '['..dark_addon.name..']|r |cffc32425' .. string .. '|r')
end

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
  
function dark_addon.format(value)
    if tonumber(value) then
    return round(value, 2)
    else
    return tostring(value)
    end
end

dark_addon.on_ready(function()
    local debug_level = dark_addon.settings.fetch('debug_level', nil)
    dark_addon.console.set_level(debug_level)
    if dark_addon.settings.fetch('_engine_enablelogfile', false) then
    dark_addon.console.logfile = dark_addon.settings.fetch('_engine_logfilename', nil)
    end
    --local toggle = dark_addon.settings.fetch('debug_show', false)
    --dark_addon.console.toggle(toggle)
    dark_addon.console.log("Welcome!")
end)
  