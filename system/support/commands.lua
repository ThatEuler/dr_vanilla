
dark_addon.commands = {
    commands = { }
}

function dark_addon.commands.register(command)
    if type(command.command) == 'table' then
        for _, command_key in ipairs(command.command) do
        dark_addon.commands.commands[command_key] = command
        end
    else
        dark_addon.commands.commands[command.command] = command
    end
end

local function format_help(command)
    local arguments = table.concat(command.arguments, ', ')
    local command_key
    if type(command.command) == 'table' then
        command_key = table.concat(command.command, '||')
    else
        command_key = command.command
    end
    return string.format('|cff%s/dr %s|r |cff%s%s|r %s', dark_addon.color2, command_key, dark_addon.color3, arguments, command.text)
end

local function handle_command(msg, editbox)
    local _, _, command, _arguments = string.find(msg, "%s?(%w+)%s?(.*)")
    local arguments = { }

    if not _arguments then
        dark_addon.log('Build ' .. dark_addon.version)
        dark_addon.log('Type /dr help for a list of known commands.')
        return
    end

    command = dark_addon.commands.commands[command]
    if command then
        result = command.callback(_arguments)
        if not result then
            dark_addon.log('Command Usage:')
            dark_addon.log(format_help(command))
        end
    else
        dark_addon.log('Command not found, type /dr help for a list of known commands.')
    end
end

dark_addon.on_ready(function()
    dark_addon.commands.register({
        command = 'help',
        arguments = { },
        text = 'Display the list of known commands',
        callback = function(rotation_name)
        dark_addon.log('Known commands:')
        local printed = { }
        for _, command in pairs(dark_addon.commands.commands) do
            if not printed[tostring(command)] then
            dark_addon.log(format_help(command))
            printed[tostring(command)] = true
            end
        end
        return true
        end
    })

    dark_addon.commands.register({
        command = 'load',
        arguments = {
        'rotation_name'
        },
        text = 'Loads the specified rotation',
        callback = function(rotation_name)
        dark_addon.settings.store('netload_rotation_release', nil)
        dark_addon.rotation.load(rotation_name)
        return true
        end
    })

    dark_addon.commands.register({
        command = 'list',
        arguments = { },
        text = 'List available rotations',
        callback = function()
        dark_addon.log('Available Rotations:')
        for name, rotation in pairs(dark_addon.rotation.rotation_store) do
            dark_addon.log(rotation.label and rotation.name .. ' - ' .. rotation.label or rotation.name)
        end
        return true
        end
    })

    dark_addon.commands.register({
        command = 'debug',
        arguments = {
            'debug_level',
        },
        text = 'Enable the debug console at the specified debug level',
        callback = function(debug_level)
            if tonumber(debug_level) then
                dark_addon.console.set_level(debug_level)
                if tonumber(debug_level) > 0 then
                dark_addon.console.toggle(true)
                else
                dark_addon.console.toggle(false)
                end
                return true
            else
                return false
            end
        end
    })

    dark_addon.commands.register({
        command = 'toggle',
        arguments = {
            'button_name',
        },
        text = 'Toggles the on/off state for the specified button',
        callback = function(button_name)
            if button_name and dark_addon.interface.buttons.buttons[button_name] then
                dark_addon.interface.buttons.buttons[button_name]:callback()
                return true
            end
            return false
        end
    })

    dark_addon.commands.register({
        command = 'econf',
        arguments = { },
        text = 'Shows the core engine config window.',
        callback = function(button_name)
            if dark_addon.econf.parent:IsShown() then
                dark_addon.econf.parent:Hide()
            else
                dark_addon.econf.parent:Show()
            end
            return true
        end
    })

    dark_addon.commands.register({
        command = 'fish',
        arguments = { },
        text = 'Toggle fishing on/off',
        callback = function()
            if dark_addon.fishing.enabled then
                dark_addon.fishing.stop()
            else
                dark_addon.fishing.start()
            end
            return true
        end
    })

    dark_addon.commands.register({
        command = 'tp',
        arguments = { 'location' },
        text = 'Teleport to location',
        callback = function(location)
            if location == "corpse" then
                local x, y, z = GetCorpsePosition()
                SetPosition(x, y, z)
            else
                local p = dark_addon.locations[location]
                if not p then
                    dark_addon.error("Unknown location: ", location)
                else
                    SetPosition(p[1], p[2], p[3])
                end
            end
            return true
        end
    })

    dark_addon.commands.register({
        command = 'herb',
        arguments = { },
        text = 'TP to closest herb',
        callback = function()
            local guids = GetGameObjects()
            local dist = 9999
            local hx, hy, hz
            local px, py, pz = UnitPosition("player")
            for ix, guid in guids do
                log("GameObject", ix, UnitName(guid))
                local name = UnitName(guid)
                if name == "Silverleaf" or name == "Peacebloom" or name == "Earthroot" or name == "Mageroyal" or name == "Briarthorn" or name == "Bruiseweed" then
                    local x, y, z = GOPosition(guid)
                    local d = math.sqrt(((px-x)*(px-x))+((py-y)*(py-y))+((pz-z)*(pz-z)))
                    if d < dist then
                        dist = d
                        hx = x; hy = y; hz = z
                    end
                end
            end
            if hx then
                SetPosition(hx, hy, hz+0.2)
            else
                chat("no herb")
            end
            return true
        end
    })

    if dark_addon.settings.fetch("speed") then
        dark_addon.speed = dark_addon.settings.fetch("speed")
    else
        dark_addon.speed = 14.0
    end
    dark_addon.commands.register({
        command = 'speed',
        arguments = { speed },
        text = 'Set move speed',
        callback = function(speed)
            if speed then
                dark_addon.settings.store("speed", speed)
                dark_addon.speed = speed
            else
                dark_addon.settings.store("speed", 7.0)
                dark_addon.speed = 7.0
            end
            return true
        end
    })

end)

SLASH_DARKROTATIONS1, SLASH_DARKROTATIONS2 = '/dark', '/dr'
SlashCmdList["DARKROTATIONS"] = handle_command
