if not PowerRounds then
    PowerRounds = {}
end

if PowerRounds.SharedLoaded then
    return
else
    PowerRounds.SharedLoaded = true
end

local GamemodePlayers, GamemodeAllPlayers
PR_ROLE_ANY = 0
PR_ROLE_BAD = 1
PR_ROLE_GOOD = 2
PR_ROLE_SPEC = 3
PR_ROLE_SPECIAL = 4

PowerRounds.Rounds = {
    ["Murder"] = {}
}

local PRIDs = 1

function PowerRounds.AddRound(RT)
    if PowerRounds.DoneRounds then return end

    if not RT.Name then
        RT.Name = "No name set"
    end

    if not RT.Gamemode then
        RT.Gamemode = "Any"
    end

    if not RT.Description then
        RT.Description = "No description set"
    end

    if SERVER then
        RT.ClientStart = nil
        RT.ClientEnd = nil

        for n, j in pairs(RT) do
            if string.StartWith(n, "CHOOK_") or string.StartWith(n, "CTIMER_") then
                RT[n] = nil
            end
        end
    elseif CLIENT then
        RT.ServerStartWait = nil
        RT.WinTeamCondition = nil
        RT.ServerStart = nil
        RT.ServerEnd = nil
        RT.PlayersStart = nil
        RT.PlayersEnd = nil
        RT.PlayerDeath = nil
        RT.DoPlayerDeath = nil
        RT.PlayerUpdate = nil
        RT.Think = nil
        RT.PlayerCanPickupWeapon = nil
        RT.PlayerShouldTakeDamage = nil
        RT.ScalePlayerDamage = nil
        RT.RunCondition = nil

        for n, j in pairs(RT) do
            if string.StartWith(n, "SHOOK_") or string.StartWith(n, "STIMER_") then
                RT[n] = nil
            end
        end
    end

    RT.ID = PRIDs
    PRIDs = PRIDs + 1

    for n, j in pairs(PowerRounds.Rounds) do
        if RT.Gamemode == "Any" or RT.Gamemode == n then
            j[RT.ID] = RT
        end
    end
end

function PowerRounds.Chat(Ply, ...)
    if CLIENT then
        chat.AddText(...)
    elseif SERVER then
        if Ply ~= "All" and not IsValid(Ply) then return end
        local T = {...}
        net.Start("PowerRoundsChat")
        net.WriteUInt(#T, 8)

        for _, j in ipairs(T) do
            if isentity(j) then
                j = j:Nick()
            end

            if j == nil then
                j = ""
            end

            if isstring(j) then
                net.WriteUInt(0, 1)
                net.WriteString(j)
            elseif istable(j) then
                net.WriteUInt(1, 1)
                net.WriteUInt(j.r or 255, 8)
                net.WriteUInt(j.g or 255, 8)
                net.WriteUInt(j.b or 255, 8)
            end
        end

        if Ply == "All" then
            net.Broadcast()
        else
            net.Send(Ply)
        end
    end
end

hook.Add("PostGamemodeLoaded", "PowerRoundsPostGamemodeLoadedSH", function()
    local GMName = GAMEMODE.Name

    -- Murder
    if GMName == "Murder" then
        PowerRounds.CurrentGM = "Murder"
        PowerRounds.CurrentGMSpecific = "Murder"

        function GamemodePlayers(Ply)
            if Ply:IsMurderer() then
                return PR_ROLE_BAD
            else
                return PR_ROLE_GOOD
            end
        end

        function GamemodeAllPlayers()
            return team.GetPlayers(2)
        end
    end

    if CLIENT then
        if PowerRounds.NextPos.TextAllignH == TEXT_ALIGN_BOTTOM and PowerRounds.NextPos.TextAllignW == TEXT_ALIGN_LEFT and PowerRounds.NextPos.H == 15 and PowerRounds.NextPos.W == 15 then
            PowerRounds.NextPos.TextAllignH = TEXT_ALIGN_TOP
        end
    else
        hook.Run("PowerRoundsPST")
    end
end)

if CLIENT then
    net.Receive("PowerRoundsChat", function()
        local Chat = {}
        local Amount = net.ReadUInt(8)

        for i = 1, Amount do
            local PType = net.ReadUInt(1)

            if PType == 0 then
                local Text = net.ReadString()
                table.insert(Chat, Text)
            elseif PType == 1 then
                local R = net.ReadUInt(8)
                local G = net.ReadUInt(8)
                local B = net.ReadUInt(8)
                table.insert(Chat, Color(R, G, B))
            end
        end

        if #Chat ~= 0 then
            chat.AddText(unpack(Chat))
        end
    end)
end

function PowerRounds.Access(Ply, Access)
    local HasAccess = false

    if ULib and PowerRounds.UseULX then
        HasAccess = ULib.ucl.query(Ply, Access)
    elseif Access == "PowerRounds_Force" then
        HasAccess = Ply:IsAdmin()
    end

    if SERVER and not HasAccess then
        MsgC(Color(255, 0, 0), "[PowerRounds] " .. Ply:Name() .. "|" .. Ply:SteamID() .. " has attempted to cheat the system! By accessing '" .. Access .. "' while not having access!")
    end

    return HasAccess
end

if SERVER then
    --[[PowerRounds.EndRound Usage:
		Arguments:
			PR_WIN_* value.   PR_WIN_BAD (muderers/traitors/hunters/guards),  PR_WIN_GOOD (bystanders/innocents/props/prisoners),  PR_WIN_NONE
			Player object(Only Murder gamemode)   Murdered from that round

	]]
    function PowerRounds.EndRound(Type)
        -- Function created elsewhere, dont mind it being empty here
    end
end

--[[PowerRounds.Players Usage:
	Arguments:
		Type number		Type ID of who to get: 1 = All, 2 = Alive(Without SpecDM), 3 = Alive(All alive), 4 = Only alive muderers/traitors/hunters/guards(Without SpecDM), 5 = Only alive bystanders/innocents/detectives/props/prisoners(Without SpecDM), 6 = All muderers/traitors/hunters/guards, 7 = All bystanders/innocents/detectives/props/prisoners
		(OPTIONAL)Player object OR table of Player objects		Player(s) to exclude from returned list.

	Returns:
		Table of player objects
]]
function PowerRounds.Players(Type, Exclude)
    local PlayerList = GamemodeAllPlayers()
    if Type == 1 then return PlayerList end
    local Players = {}

    for _, v in pairs(PlayerList) do
        if (not istable(Exclude) and v ~= Exclude) or (istable(Exclude) and not table.HasValue(Exclude, v)) then
            if Type == 2 then
                if v:Alive() and not v:GetNWBool("SpecDM_Enabled", false) then
                    table.insert(Players, v)
                end
            elseif Type == 3 then
                if v:Alive() then
                    table.insert(Players, v)
                end
            elseif (Type == 4 and v:Alive() and not v:GetNWBool("SpecDM_Enabled", false)) or Type == 6 then
                local Role = GamemodePlayers(v, Type)

                if Role == PR_ROLE_ANY or Role == PR_ROLE_BAD then
                    table.insert(Players, v)
                end
            elseif (Type == 5 and v:Alive() and not v:GetNWBool("SpecDM_Enabled", false)) or Type == 7 then
                local Role = GamemodePlayers(v, Type)

                if Role == PR_ROLE_ANY or Role == PR_ROLE_GOOD then
                    table.insert(Players, v)
                end
            end
        end
    end

    return Players
end