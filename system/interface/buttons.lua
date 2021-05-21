
dark_addon.interface.status = function(text)
    dr_status:SetText(text)
end
  
dark_addon.interface.status_extra = function(text)
    dr_status_extra:SetText(text)
end

dark_addon.interface.set_master = function(is_on)
    if is_on then
        master_toggle_text:SetText("On")
    else
        master_toggle_text:SetText("Off")
    end
    dark_addon.settings.store("master_toggle", is_on)
end

function dark_addon.interface.set_damage(value)
    dark_addon.settings.store("damage_toggle", value)
end

function dark_addon.interface.set_healing(value)
    dark_addon.settings.store("healing_toggle", value)
end

dark_addon.on_ready(function()
    local is_on = dark_addon.settings.fetch("master_toggle")
    if is_on then
        master_toggle_text:SetText("On")
    else
        master_toggle_text:SetText("Off")
    end
    master_toggle:SetChecked(is_on)
    damage_toggle:SetChecked(dark_addon.settings.fetch("damage_toggle"))
    healing_toggle:SetChecked(dark_addon.settings.fetch("healing_toggle"))
end)