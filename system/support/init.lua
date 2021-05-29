dark_addon = {}

dark_addon.name = 'DarkRotations Vanilla'
dark_addon.id = 'dr_vanilla'
dark_addon.version = 'r001'
dark_addon.color = 'ebdec2'
dark_addon.color2 = 'ebdec2'
dark_addon.color3 = 'ebdec2'
dark_addon.ready = false
dark_addon.settings_ready = false
dark_addon.ready_callbacks = { }
dark_addon.protected = true
dark_addon.cooldowns = { }

function dark_addon.on_ready(callback)
  dark_addon.ready_callbacks[callback] = callback
end
