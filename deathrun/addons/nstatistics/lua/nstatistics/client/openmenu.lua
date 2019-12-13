function NSTATISTICS.OpenMenu()
	if table.HasValue(NSTATISTICS.config.MenuAccess, LocalPlayer():GetUserGroup()) then
		if IsValid(NSTATISTICS.menu) then
			NSTATISTICS.menu:Show()
		else
			NSTATISTICS.menu = vgui.Create("nstatistics_menu")
		end
	else
		chat.AddText(Color(255, 0, 0), "You don't have access to nStatistics menu")
	end
end

function NSTATISTICS.CloseMenu()
	if IsValid(NSTATISTICS.menu) then
		NSTATISTICS.menu:Hide()
	end

	if IsValid(NSTATISTICS.DatePopup) and NSTATISTICS.DatePopup:IsVisible() then
		NSTATISTICS.DatePopup:Hide()
	end
end

function NSTATISTICS.ToggleMenu()
	if IsValid(NSTATISTICS.menu) and NSTATISTICS.menu:IsVisible() then
		NSTATISTICS.CloseMenu()
	else
		NSTATISTICS.OpenMenu()
	end
end

function NSTATISTICS.ReloadMenu()
	if IsValid(NSTATISTICS.menu) then
		local visible = NSTATISTICS.menu:IsVisible()

		NSTATISTICS.menu:Remove()

		if IsValid(NSTATISTICS.DatePopup) then
			NSTATISTICS.DatePopup:Remove()
		end

		if visible then
			NSTATISTICS.OpenMenu()
		end
	end
end

concommand.Add(NSTATISTICS.config.ConCommand, NSTATISTICS.ToggleMenu)

concommand.Add("nstatistics_reloadmenu", NSTATISTICS.ReloadMenu)

hook.Add(
	"OnPlayerChat",
	"NStatistics_OpenMenu",
	function(ply, text)
		if ply == LocalPlayer() and text == NSTATISTICS.config.ChatCommand then
			NSTATISTICS.ToggleMenu()
		end
	end
)
