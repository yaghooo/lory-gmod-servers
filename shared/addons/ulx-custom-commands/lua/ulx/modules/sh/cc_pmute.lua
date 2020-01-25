----------------------------------------
--  This file holds the PMute command  --
----------------------------------------

function ulx.pmute(calling_ply, target_plys, should_unmute)
	if should_unmute then
		for k, v in pairs(target_plys) do
			v:RemovePData("permmutted")

			v.perma_mutted = false
		end

		ulx.fancyLogAdmin(calling_ply, "#A un-permamutted #T ", target_plys)
	elseif (not should_unmute) then
		for k, v in pairs(target_plys) do
			v:SetPData("permmutted", "true")

			v.perma_mutted = true
		end

		ulx.fancyLogAdmin(calling_ply, "#A permanently mutted #T", target_plys)
	end
end
local pmute = ulx.command("Chat", "ulx pmute", ulx.pmute, "!pmute")
pmute:addParam {type = ULib.cmds.PlayersArg}
pmute:addParam {type = ULib.cmds.BoolArg, invisible = true}
pmute:defaultAccess(ULib.ACCESS_ADMIN)
pmute:help("Mute target(s), disables microphone using pdata.")
pmute:setOpposite("ulx unpmute", {_, _, true}, "!unpmute")

local function pmuteHook(talker)
	if talker.perma_mutted == true then
		return false
	end
end
hook.Add("PlayerSay", "pdatamute", pmuteHook)

---- functions to check if players are mutted upon them leaving and joining ----
function pmutePlayerDisconnect(ply)
	if ply:GetPData("permmutted") == "true" then
		for k, v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				ULib.tsayError(v, ply:Nick() .. " has left the server and is permanently mutted.")
			end
		end
	end
end
hook.Add("PlayerDisconnected", "pmutedisconnect", pmutePlayerDisconnect)

function pmuteuserAuthed(ply)
	local pdata = ply:GetPData("permmutted")

	if pdata == "true" then
		ply.perma_mutted = true

		for k, v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				ULib.tsayError(v, ply:Nick() .. " has joined and is permanently mutted.")
			end
		end
	else
		ply.perma_mutted = false
	end
end
hook.Add("PlayerAuthed", "pmuteauthed", pmuteuserAuthed)

---- function to list players who are pmutted ----
function ulx.printpmutes(calling_ply)
	pmutted = {}

	for k, v in pairs(player.GetAll()) do
		if v:GetPData("permmutted") == "true" then -- find all players who have "mutted" set to true
			table.insert(pmutted, v:Nick())
		end
	end

	local pmutes = table.concat(pmutted, ", ") -- concatenate each player in the table with a comma

	ulx.fancyLog({calling_ply}, "Pmutted: #s ", pmutes) -- only prints this to the player who called the function
end
local printpmutes = ulx.command("Chat", "ulx printpmutes", ulx.printpmutes, "!printpmutes", true)
printpmutes:defaultAccess(ULib.ACCESS_ADMIN)
printpmutes:help("Prints players who are pmutted.")
