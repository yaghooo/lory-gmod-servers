local AFKLimit = CreateConVar("antiafk_limit", 60 * 15, FCVAR_NONE, "Max time in seconds player can stay AFK before being kicked", 20)

hook.Add("PlayerChangedTeam", "CheckAFKPlayer", function(ply)
    local identifier = "AFKCheck" .. ply:SteamID()

    if ply.Spectating then
        timer.Create(identifier, AFKLimit:GetInt() - 10, 1, function()
            ply:ChatPrint("Você será kickado em 10 segundos se continuar de espectador")

            timer.Create(identifier, 10, 1, function()
                if ply.Spectating and player.GetCount() > 10 then
                    ply:Kick("Ficou muito tempo como um espectador.")
                end
            end)
        end)
    else
        timer.Remove(identifier)
    end
end)