
dark_addon.fishing = { }
local F = dark_addon.fishing
F.enabled = false

local Start = 0
local WaitForCatch = 1
local Cooldown = 2

local function reset()
    F.bobber = nil
    F.casttime = 0
    F.state = Start
    F.cooldown = 0    
end

local function find_bobber()
    guids = GetGameObjects()
    local nbobbers = 0
    for _, guid in ipairs(guids) do
        --log("Name", UnitName(guid))
        if UnitName(guid) == "Fishing Bobber" then
            nbobbers = nbobbers + 1
            F.bobber = guid
        end
    end
    if nbobbers > 1 then
        log("found multiple bobbers (",nbobbers,").  go fish somewhere else.")
        dark_addon.fishing.stop()
        return nil
    else
        return F.bobber
    end
end

function dark_addon.fishing.start()
    log("start fishing")
    dark_addon.fishing.enabled = true
end


function dark_addon.fishing.stop()
    log("stop fishing")
    dark_addon.fishing.enabled = false
end


function dark_addon.fishing.fish()
    dark_addon.interface.status('Fishing...')

    if UnitStandState('player') == 1 then
        SitOrStand()
        return
    end

    if F.bobber and UnitName(F.bobber) == "Unknown" then
        --log("invalid bobber. reset")
        reset()
        return
    end

    if F.state == Start then
        if find_bobber() then
            log("got bobber", F.bobber)
            F.state = WaitForCatch
            return
        end
        if (GetTime() - F.casttime) > 1 then
            log("Cast")
            CastSpellByName("Fishing")
            F.casttime = GetTime()
        end
        return
    end

    if F.state == WaitForCatch then
        --log("type", type(F.bobber), "bobber state", BobberState(F.bobber))
        if BobberState(F.bobber) == 1 then
            log("catch")
            RightClickGameObject(F.bobber)
            F.cooldown = GetTime() + 1
            F.state = Cooldown            
        end
        return
    end

    if F.state == Cooldown then
        if GetTime() > F.cooldown then
            reset()
        end
        return
    end
end

reset()
