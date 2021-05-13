
local function draw()
    if target.exists then
        local px, py, pz = player.position()
        local tx, ty, tz = target.position()
        LibDraw.SetColor(192, 57, 43, 0.5)
        LibDraw.Line(px, py, pz, tx, ty, tz)
    end
end
dark_addon.environment.hook(draw)

--dark_addon.on_ready(function()
--    LibDraw.Sync(draw)
--    LibDraw.Enable(0.05)
--end)
