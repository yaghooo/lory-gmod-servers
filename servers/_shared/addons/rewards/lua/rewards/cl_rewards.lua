local chatCommand = "!rewards"
local buttonCommand = "F4"

hook.Add("OnPlayerChat", "REWARDS_ToggleCommand", function(ply, text, team, dead)
	if ply == LocalPlayer() and string.lower(text) == chatCommand then
		REWARDS:ToggleRewardsMenu()
	end
end)

hook.Add("PlayerButtonDown", "REWARDS_ToggleKey", function(ply, btn)
	if IsFirstTimePredicted() and ply == LocalPlayer() and btn == _G["KEY_" .. buttonCommand] then
		REWARDS:ToggleRewardsMenu()
	end
end)

function REWARDS:ToggleRewardsMenu()
	-- Wait prizes for load
	if not REWARDS.Prizes then return end

	if not REWARDS.Page or not REWARDS.Page:IsValid() then
		REWARDS.Page = REWARDS:OpenPage()
	else
		REWARDS.Page:Close()
	end
end


net.Receive("rewards_prizes", function()
	local prizes = util.JSONToTable(net.ReadString())
	REWARDS.Prizes = prizes

	timer.Simple(5, function()
		local prizesToClaim = 0

		for k, v in pairs(REWARDS.Prizes) do
			if v.Status == "RESGATAR" then
				prizesToClaim = prizesToClaim + 1
			end
		end

		if prizesToClaim != 0 then
			local plural = prizesToClaim == 1 and "" or "s"
			local parse = {
				THEME.Color.Primary,
				"Você tem " .. prizesToClaim .. " prêmio" .. plural .. " para resgatar! Digite " .. chatCommand .. " ou aperte " .. buttonCommand .. "."
			}
			chat.AddText(unpack(parse))
		end

		REWARDS.PrizesToClaim = prizesToClaim
	end)
end)
