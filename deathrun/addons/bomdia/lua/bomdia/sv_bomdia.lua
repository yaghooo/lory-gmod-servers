if SERVER then
	local possibleCommands = {
		"bom dia",
		"good morning",
		"buenos dias"
	}

	sql.Query("CREATE TABLE IF NOT EXISTS bomdia ( `sid64` STRING, `bomdias` INT, PRIMARY KEY(sid64) )")

	hook.Add(
		"PlayerSay",
		"HelloCommand",
		function(ply, strText, bTeam)
			local strTextMin = string.lower(strText)

			if table.HasValue(possibleCommands, strTextMin) then
				if not ply.lastBomDia or ply.lastBomDia < CurTime() then
					ply.lastBomDia = CurTime() + GetConVar("bomdia_interval_time"):GetInt()

					sql.Query(
						"INSERT OR IGNORE INTO `bomdia` (sid64, bomdias) VALUES ('" ..
							ply:SteamID64() .. "', 0); UPDATE `bomdia` SET bomdias = bomdias + 1 WHERE sid64 = '" .. ply:SteamID64() .. "'"
					)

					local bomdia = math.random()

					if bomdia > GetConVar("bomdia_cabuloso_rate"):GetFloat() then
						GiveBomDiaCabuloso(ply, strTextMin)
					else
						GiveBomDia(ply, strTextMin)
					end

					return ""
				end
			end
		end
	)

	util.AddNetworkString("write_chat")

	function GiveBomDia(ply, command)
		local color = Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))

		local parse = {}
		table.insert(parse, color)
		table.insert(parse, ply:GetName() .. " deu " .. command .. " para todos do servidor!")

		net.Start("write_chat")
		net.WriteString(util.TableToJSON(parse))
		net.WriteBit(0)
		net.Broadcast()
	end

	function GiveBomDiaCabuloso(ply, command)
		local points = GetConVar("bomdia_cabuloso_points"):GetInt()
		local color = Color(255, 215, 0)

		local parse = {}
		table.insert(parse, color)
		table.insert(
			parse,
			ply:GetName() .. " deu um " .. command .. " cabuloso! Todos os jogadores ganharam " .. points .. " pontos!"
		)

		net.Start("write_chat")
		net.WriteString(util.TableToJSON(parse))
		net.WriteBit(1)
		net.Broadcast()

		for k, v in pairs(player.GetAll()) do
			v:PS_GivePoints(points)
		end
	end
end
