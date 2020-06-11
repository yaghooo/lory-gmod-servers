local AFKLimit = CreateConVar("antiafk_limit", 60 * 15, FCVAR_NONE, "Max time in seconds player can stay AFK before being kicked", 20)

hook.Add("PlayerChangedTeam", "CheckAFKPlayer", function(ply, old, new)
    local identifier = "AFKCheck" .. ply:SteamID()

    if new == TEAM_SPECTATOR then
        timer.Create(identifier, AFKLimit:GetInt() - 10, 1, function()
            if IsValid(ply) and new == TEAM_SPECTATOR and player.GetCount() > 10 then
                ply:ChatPrint("Você será kickado em 10 segundos se continuar de espectador")

                timer.Create(identifier, 10, 1, function()
                    if new == TEAM_SPECTATOR then
                        ply:Kick("Ficou muito tempo como um espectador.")
                    end
                end)
            end
        end)
    else
        timer.Remove(identifier)
    end
end)