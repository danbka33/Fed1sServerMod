local SoftReset = {}

function SoftReset.reset()
    Chests.on_init()
    AdminMessage.on_init()
    PlayersInventory.on_init()
    ServerMod.on_init()
    Statistics.on_init()
    Stats.on_init()

    table.insert(AdminMessage.get_make_admin_texts(), {
        tick = game.tick,
        playerName = "SERVER",
        message = "GG",
        admin = true,
        manager = true,
        role = "Admin"
    })

    for _, player in pairs(game.players) do
        AdminMessage.update_overhead_texts(player)
        player.play_sound({ path = "soft_reset_notify" })
    end
end

remote.add_interface("soft_reset_scenario", { soft_reset = SoftReset.reset })

return SoftReset
