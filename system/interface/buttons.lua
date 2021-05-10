
dark_addon.interface.status = function(text)
    dr_status:SetText(text)
end
  
dark_addon.interface.status_extra = function(text)
    --info_frame.text_right:SetText(text)
end

dark_addon.interface.set_master = function(is_on)
    if is_on then
        master_toggle_text:SetText("On")
    else
        master_toggle_text:SetText("Off")
    end
    dark_addon.settings.store("master_toggle", is_on)
end

dark_addon.on_ready(function()
    local is_on = dark_addon.settings.fetch("master_toggle")
    if is_on then
        master_toggle_text:SetText("On")
    else
        master_toggle_text:SetText("Off")
    end
    master_toggle:SetChecked(is_on)
end)