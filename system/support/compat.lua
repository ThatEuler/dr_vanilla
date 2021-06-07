
local Time = 0
local Tickers = {}
C_Timer = {}

local function OnUpdate(elapsed)
    Time = Time + elapsed

    for _, timer in pairs(Tickers) do
        if timer.last_tick == 0 or (Time - timer.last_tick) >= timer.period then
            timer.last_tick = Time
            timer.func()
        end
    end
end
dark_addon.OnUpdate = OnUpdate

function C_Timer.NewTicker(period, func)
    local t = {}
    t.period = period
    t.last_tick = 0
    t.func = func
    t.Cancel = function(self)
        Tickers[self.func] = nil
    end

    Tickers[func] = t
    return t
end

function log(...)
    msg = tostring(arg[1])
    for i = 2, arg.n do
        msg = msg .. " " .. tostring(arg[i])
    end
    --DEFAULT_CHAT_FRAME:AddMessage(msg)
    L(msg)
end
dark_addon.log = log

function chat(...)
    msg = tostring(arg[1])
    for i = 2, arg.n do
        msg = msg .. " " .. tostring(arg[i])
    end
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end
dark_addon.chat = chat

function string.ends_with(str, ending)
    return ending == "" or string.sub(str, -string.len(ending)) == ending
end

function UnitInRange(unit)
    local dist = GetDistanceBetweenUnits('player', unit)
    return dist and dist <= 40
end
