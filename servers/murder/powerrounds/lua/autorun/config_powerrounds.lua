if not PowerRounds then
    PowerRounds = {}
end

include("sh_powerrounds.lua")
--
--[[ Main Settings ]]
PowerRounds.ShowForPlayer = true -- Should it show the text in te middle of screen when round starts on everyones screen
PowerRounds.PREvery = 5 -- Will run a PR every {set} rounds
PowerRounds.SameInRow = false -- Should same PR be able to start 2 times in a row
PowerRounds.ChatCommand = "!prmenu" -- Command that you type in chat to open power round menu
PowerRounds.ChatInfoCommand = "!prinfo" -- Command that you type in chat to show name and description of the current PR
PowerRounds.ChatInfoText = "Power round atual é '{Name}' o que faz '{Description}'" -- Text that will appear when a person writes in chat for PR info. {Name} = Name of the PR, {Description} = Nescription of the PR
PowerRounds.ChatInfoNotPRText = "Round atual não é um power round" -- Text that will appear when a person writes in chat for PR info , but it isn't a PR round.
PowerRounds.UseULX = true -- If true addon will use ULX permissions for stuff like forcing PR in menu, if false it will use default built in admin, If ULX will not be available it will just use default built in admin
PowerRounds.ForceNotify = true -- If true the ForceChatText will appear in chat when a PR is forced, if false only the person forcing it will see the text
PowerRounds.ForceChatText = "{ForcerName} forçou o proximo round para ser '{PRName}'" -- Text that will appear in chat when a round is forced. {ForcerName} = Name of person that forced it, {PRName} = Name of the round forced
PowerRounds.ForceChatColor = Color(0, 255, 0) -- Color that the text in chat will be
--[[New]]
PowerRounds.NoAccessChatText = "Você não tem permissão para fazer isto." -- Text that appears in chat if they try to open Power Round menu without having access
--[[New]]
PowerRounds.NoAccessChatColor = Color(255, 0, 0) -- Color that the No Access text in chat will be
PowerRounds.SaveOverMap = true --[[ Client Settings ]] -- Should the round counter carry over maps?

--
--
--[[ End of Main Settings ]]
-- Don't touch
if CLIENT then
    PowerRounds.InfoShowTime = 10 -- How long the text and description should be shown [default: 10 (Same as default Murder black screen)]
    PowerRounds.MaxInfoWidth = ScrW() / 2 -- At what text and description width it should continue text in new line on screen [default: ScrW() / 2 (Half of screen size)]

    -- Divides screen height/width in half, so text is in the middle [default: { H = ScrH() / 3, W = ScrW() / 2 } (Middle of screen)]
    PowerRounds.InfoPos = {
        H = ScrH() / 2.5,
        W = ScrW() / 2
    }

    PowerRounds.MenuFont = "coolvetica" -- http://wiki.garrysmod.com/page/Default_Fonts All gmod default font names available there
    PowerRounds.NameSize = 60 -- Font size for the PRs name text
    PowerRounds.NameFont = "coolvetica" -- http://wiki.garrysmod.com/page/Default_Fonts All gmod default font names available there
    PowerRounds.DescriptionSize = 35 -- Font size for the PRs description
    PowerRounds.DescriptionFont = "coolvetica" -- http://wiki.garrysmod.com/page/Default_Fonts All gmod default font names available there
    PowerRounds.ShowUntilNext = true -- Should it show how many rounds are left until next PR

    -- Divides screen height/width in half, so text is in the middle [default: { H = 1, W = 1 } (Top left corner)], TextAllign values: TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, TEXT_ALIGN_BOTTOM
    PowerRounds.NextPos = {
        H = 15,
        W = 15,
        TextAllignH = TEXT_ALIGN_TOP,
        TextAllignW = TEXT_ALIGN_LEFT
    }

    PowerRounds.NextClr = Color(255, 255, 255, 255) -- Color that the number should be
    PowerRounds.NextSize = 30 -- Size of the font for the text
    PowerRounds.NextTextOne = "Próximo round será um power round" -- Text when only one round is left until next PR {Num} = Rounds left, number
    PowerRounds.NextTextMultiple = "{Num} rounds para um power round" -- Text when more than 1 round is left until next PR {Num} = Rounds left, number
    PowerRounds.NextTextCurrent = "Power Round" -- Text when this round is the PR
    PowerRounds.NextTextForced = " Power Round" -- Text when this round is a forced PR
    PowerRounds.NextFont = "coolvetica" -- http://wiki.garrysmod.com/page/Default_Fonts All gmod default font names available there
    PowerRounds.Menu = {}
    PowerRounds.Menu.BGColor = Color(35, 35, 35, 255)
    PowerRounds.Menu.FGColor = Color(42, 42, 42, 255)
    PowerRounds.Menu.TitleColor = Color(19, 121, 245, 255)
    PowerRounds.Menu.CloseBtnColor = Color(151, 151, 151, 255)
    PowerRounds.Menu.CloseBtnBorderColor = Color(0, 0, 0, 255)
    PowerRounds.Menu.CloseBtnTextColor = Color(255, 255, 255, 255)
    PowerRounds.Menu.ForceBtnColor = Color(151, 151, 151, 255)
    PowerRounds.Menu.ForceBtnBorderColor = Color(0, 0, 0, 255)
    PowerRounds.Menu.ForceBtnTextColor = Color(255, 255, 255, 255)
end

--[[
	Gamemode names(Use the ones for Gamemode config for a round):
		Any = Will run on any supported gamemode
		Murder = Murder
	]]
--[[ All possible values for a power round
	PowerRounds.AddRound({
		Name = "Any Text",                                          --Any text, will be the power rounds name {Default: ""}
		Gamemode = "Any",                                           --Which gamemode should this Power ROund be for {Default: "Any"} Can be one of these: "TTT", "Murder", "Any"
		Description = "Any Text",                                   --Any text, will be the power rounds description {Default: ""}
		CustomRoundEnd = false,                                     --Will the round end in a custom way {Default: false} !!!If you set this to true, remember to have code that will end the round!!!
        ServerStartWait = 10,                                       --Time that the server should wait before running ServerStart function {Default: 0 | No waiting}
		WinTeamCondition = function(Ply) return Ply:Alive() end,    --Function that will run for every player playing when the round ends {Default: if player is alive} [Values: Ply = player] (Return: true = winner, false = not winner)
		ServerStart = function() end,                               --Function that will run when round starts {Default: empty function} (Runs once)
		ServerEnd = function(Winners, Losers) end,                  --Function that will run when round ends {Default: empty function} [Values: Winners = table of this rounds winners, Losers = table of this rounds losers]
		PlayersStart = function(Ply) end,                           --Function that will run for every player playing when round starts {Default: empty function} [Values: Ply = player]
		PlayersEnd = function(Ply, IsWinner) end,                   --Function that will run for every player playing when round ends {Default: empty function} [Values: Ply = player, IsWinner = Value returned by WinTeamCondition for that player]
		PlayerDeath = function(Ply, Attacker) end,                  --Function that will run when a person dies {Default: empty function} [Values: Ply = killed player, Attacker = killer] (Return: true = will stop things like: Punishment for teamkill)
		DoPlayerDeath = function(Ply, Attacker, DMGInfo) end,       --Function that will run when a person dies {Default: empty function} [Values: Ply = killed player, Attacker = killer, DMGInfo = damage info] (Return: true = will not create a ragdoll or add deaths)
		PlayerUpdate = function(Ply, Type, *Attacker*) end,         --**Attacker is only returned on player update that involves death** Function that will run when a person dies, goes spectator or disconnects {Default: empty function} [Values: Ply = player, Type = PR_PUPDATE_DISCONNECT or PR_PUPDATE_DIE or PR_PUPDATE_SPECTATOR,Attacker = killer]
		Think = function() end,                                     --Runs on every think hook {Default: empty function}
		PlayerCanPickupWeapon = function(Ply, Ent) end,             --Function that will run when a person gets a gun {Default: empty function} [Values: Ply = player, Ent = weapon] (Return: true = will let picking up, false = will not)
		PlayerShouldTakeDamage = function(Ply, Ent) end,            --Function that will run when a person gets hurt {Default: empty function} [Values: Ply = player, Ent = player that hurt] (Return: true = will take damage, false = will not)
		ScalePlayerDamage = function(Ply, HitGroup, DMGInfo) end,   --Function that will run when a person gets hurt {Default: empty function} [Values: Ply = player, HitGroup = where the person was hit, DMGInfo = damage info] (Return: Edited DMGInfo)
		RunCondition = function() return true end,                  --Function that will run when this PR is randomly chosen for the next round {Default: Always allow} (Return: true = Allows the round to be chosen, false = Disallows)

		HUDPaint = function() end,                                  --{Client only, of course :D }Function that can be used for drawing stuff on screen {Default: empty function} (Runs in the HUDPaint hook while the round is going)
		ClientStart = function() end,                               --{Client only}Function that will run when round starts {Default: empty function} (Runs once)
		ClientEnd = function() end,                                 --{Client only}Function that will run when round ends {Default: empty function} (Runs once)

		SHOOK_HookName = function(hook provided parameters) end,	--{Server only} Easier and more clean way of adding other hooks to your round, automatically added when round starts and removed when it ends for example for OnPlayerChat hook you'd make the function SHOOK_OnPlayerChat  (Return: Anything you want to be returned in the hook)
		CHOOK_HookName = function(hook provided parameters) end,	--{Client only} Used same as SHOOK_, usable client side, while SHOOK_ is server side  (Return: Anything you want to be returned in the hook)

		STIMER_Num_Repeat_Name = function() end,					--{Server only} Easier and more clean way of adding repeating timers to your round, automatically added when round starts and removed when it ends
																		for example you want a timer that repeats every 3 seconds, you'd make the function name STIMER_3_AnyNameHere
																		or if you only want to to run twice, once after 3 seconds, then again after 3 more, then for example, do   STIMER_3_2_AnyNameHere
																		Can also be used as STIMER_Num_Name then Repeat defaults to 0 and the timer keeps repeating until round end
																		If you need to access the timer to reset it or whatever, the name gets set to    PowerRoundsTimer_Name       Name being the one you set in the function name
		CTIMER_Num_Repeat_Name = function() end,					--{Client only} Same as STIMER_ just runs on client side
	})



	While the round is going you can access the round table with PowerRounds.CurrentPR
	So you can add your own functions and name them whatever you want and then access them using PowerRounds.CurrentPR.YourFunctionNameHere

		Other standalone useful functions can be found in sh_powerrounds.lua line 358
]]

PowerRounds.AddRound({
    Name = "Assassino invisível",
    Gamemode = "Murder",
    Description = "O assassino é invísivel, mas sua localização é revelada de 10 em 10 segundos. Todos inocentes têm a arma.",
    PlayersStart = function(Ply)
        if Ply:IsMurderer() then
            Ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            Ply:SetColor(color_transparent)
        else
            Ply:Give("weapon_mu_magnum")
        end

    end,
    PlayersEnd = function(Ply)
        if Ply:IsMurderer() then
            Ply:SetRenderMode(RENDERMODE_NORMAL)
	    Ply:SetColor(color_white)
        end

    end,
    ServerStart = function()
        RunConsoleCommand("mu_murderer_fogtime", "10")
    end,
    ServerEnd = function()
        RunConsoleCommand("mu_murderer_fogtime", "240")
    end
})

PowerRounds.AddRound({
    Name = "Sem comunicação",
    Gamemode = "Any",
    Description = "A comunicação por voz e bate-papo está desativada!",
    SHOOK_PlayerCanHearPlayersVoice = function() return false end,
    SHOOK_PlayerCanSeePlayersChat = function() return false end,
    CHOOK_OnPlayerChat = function(Ply, Msg, Team, Dead)
        if Dead then return true end
    end,
    ServerStart = function()
        local PlyMeta = FindMetaTable("Player")
        TempOldSendLastWordsForPR = PlyMeta.SendLastWords
        PlyMeta.SendLastWords = function() end
    end,
    ServerEnd = function()
        local PlyMeta = FindMetaTable("Player")
        PlyMeta.SendLastWords = TempOldSendLastWordsForPR
        TempOldSendLastWordsForPR = nil
    end
})

PowerRounds.AddRound({
    Name = "Assassino apelão",
    Gamemode = "Murder",
    Description = "Todos os inocentes pegam uma arma, mas o assassino recebe um RPG e granadas, além de uma vida extra, dependendo de quantos inocentes existem.",
    PlayersStart = function(Ply)
        if Ply:IsMurderer() then
            Ply:Give("weapon_rpg")
            Ply:Give("weapon_frag")
            Ply:SetAmmo(20, 10) -- set frag ammo to 20
            Ply:SetAmmo(3, 8) -- set RPG ammo to 3
            local PlayerNum = #PowerRounds.Players(2) - 1
            Ply:SetHealth(math.max(PlayerNum * 100, 1200))
        else
            Ply:Give("weapon_mu_magnum")
        end
    end
})

PowerRounds.AddRound({
    Name = "Gratis para todos de RPG",
    Gamemode = "Murder",
    Description = "Sem armas ou facas, mas todos recebem um RPG com muita munição!",
    CustomRoundEnd = true,
    PlayerDeath = function() return true end,
    PlayerCanPickupWeapon = function() return true end,
    PlayerUpdate = function(Ply)
        local alivePlayers = PowerRounds.Players(2, Ply)

        if #alivePlayers < 2 then
            if IsValid(alivePlayers[1]) then
                local points = 250
                PowerRounds.Chat("All", "<hsv>" .. alivePlayers[1]:Name() .. " venceu a rodada e levou " .. points .. " " .. PS.Config.PointsName .. "!</hsv>")
                alivePlayers[1]:PS_GivePoints(points)
                alivePlayers[1]:PS_Notify("Você ganhou ", points, " ", PS.Config.PointsName, " por vencer o power round!")
            end

            PowerRounds.EndRound(PR_WIN_GOOD, alivePlayers[1])
        end
    end,
    PlayersStart = function(Ply)
        Ply:SetMurderer(false)
        Ply:CalculateSpeed()

        if Ply:HasWeapon(Ply:GetKnife()) then
            Ply:StripWeapon(Ply:GetKnife())
        end

        if Ply:HasWeapon("weapon_mu_magnum") then
            Ply:StripWeapon("weapon_mu_magnum")
        end

        Ply:Give("weapon_rpg")
        Ply:SelectWeapon("weapon_rpg")
        Ply:SetAmmo(9999, 8) -- set RPG ammo to 9999
    end,
    AllowRDM = true
})

PowerRounds.AddRound({
    Name = "Gratis para todos",
    Gamemode = "Murder",
    Description = "Você pega uma arma e uma faca, mata todos que você vê! Último em pé vence!",
    CustomRoundEnd = true,
    PlayerDeath = function() return true end,
    PlayerCanPickupWeapon = function() return true end,
    PlayerUpdate = function(Ply)
        local alivePlayers = PowerRounds.Players(2, Ply)

        if #alivePlayers < 2 then
            if IsValid(alivePlayers[1]) then
                local points = 250
                PowerRounds.Chat("All", "<hsv>" .. alivePlayers[1]:Name() .. " venceu a rodada e levou " .. points .. " " .. PS.Config.PointsName .. "!</hsv>")
                alivePlayers[1]:PS_GivePoints(points)
                alivePlayers[1]:PS_Notify("Você ganhou ", points, " ", PS.Config.PointsName, " por vencer o power round!")
            end

            PowerRounds.EndRound(PR_WIN_GOOD, alivePlayers[1])
        end
    end,
    PlayersStart = function(Ply)
        Ply:SetMurderer(false)
        Ply:Give("weapon_mu_magnum")
        Ply:Give(Ply:GetKnife())
        Ply:CalculateSpeed()
    end,
    AllowRDM = true
})

PowerRounds.AddRound({
    Name = "Quake",
    Gamemode = "Murder",
    Description = "Atire primeiro, pergunte depois! Último em pé vence!",
    CustomRoundEnd = true,
    PlayerDeath = function() return true end,
    PlayerCanPickupWeapon = function() return true end,
    PlayerUpdate = function(Ply)
        local alivePlayers = PowerRounds.Players(2, Ply)

        if #alivePlayers < 2 then
            if IsValid(alivePlayers[1]) then
                local points = 250
                PowerRounds.Chat("All", "<hsv>" .. alivePlayers[1]:Name() .. " venceu a rodada e levou " .. points .. " " .. PS.Config.PointsName .. "!</hsv>")
                alivePlayers[1]:PS_GivePoints(points)
                alivePlayers[1]:PS_Notify("Você ganhou ", points, " ", PS.Config.PointsName, " por vencer o power round!")
            end

            PowerRounds.EndRound(PR_WIN_GOOD, alivePlayers[1])
        end
    end,
    PlayersStart = function(Ply)
        if IsValid(Ply) then
            Ply:SetMurderer(false)

            if Ply:HasWeapon("weapon_mu_magnum") then
                Ply:StripWeapon("weapon_mu_magnum")
            end

            Ply:StripWeapon("weapon_mu_hands")
            Ply:Give("weapon_stunstick")
            Ply:Give("weapon_shotgun")
            Ply:SetAmmo(50, 7)
            Ply:Give("weapon_crossbow")
            Ply:SetAmmo(30, 6)
            Ply:SetRunSpeed(450)
            Ply:SetWalkSpeed(450)
        end
    end,
    AllowRDM = true
})

PowerRounds.AddRound({
    Name = "Gato e ratos",
    Gamemode = "Murder",
    Description = "Nenhum inocente pega armas, mas o assassino pega uma faca e uma arma, mas ele só tem 2 minutos para matar todo mundo antes dos inocentes vencerem!",
    ServerStartWait = 10,
    PlayerCanPickupWeapon = function(Ply) return Ply:IsMurderer() end,
    PlayersStart = function(Ply)
        if Ply:HasWeapon("weapon_mu_magnum") then
            Ply:StripWeapon("weapon_mu_magnum")
        end

        if Ply:IsMurderer() then
            Ply:Give("weapon_mu_magnum")
            Ply:Give(Ply:GetKnife())
        end
    end,
    PlayerUpdate = function(Ply)
        local alivePlayers = PowerRounds.Players(2, Ply)

        if #alivePlayers == 1 and IsValid(alivePlayers[1]) and alivePlayers[1]:IsMurderer() then
            local points = 250
            PowerRounds.Chat("All", "<hsv>" .. alivePlayers[1]:Name() .. " venceu a rodada e levou " .. points .. " " .. PS.Config.PointsName .. "!</hsv>")
            alivePlayers[1]:PS_GivePoints(points)
            alivePlayers[1]:PS_Notify("Você ganhou ", points, " ", PS.Config.PointsName, " por vencer o power round!")
        end
    end,
    STIMER_120_1_RoundEnd = function()
        local murderer = GAMEMODE:GetMurderer()

        if IsValid(murderer) then
            PowerRounds.EndRound(PR_WIN_GOOD, murderer)
        else
            PowerRounds.EndRound(PR_WIN_GOOD)
        end
    end
})

PowerRounds.AddRound({
    Name = "Batata quente",
    Gamemode = "Murder",
    Description = "Quando o assassino esfaqueia alguém, ele se torna o novo assassino. A cada 30 segundos o assassino atual morre e uma nova pessoa se torna assassina",
    CustomRoundEnd = true,
    ServerStartWait = 10,
    PlayerCanPickupWeapon = function(Ply, Wep) return Ply:IsMurderer() and Wep:GetClass() == Ply:GetKnife() end,
    PlayersStart = function(Ply)
        if Ply:HasWeapon("weapon_mu_magnum") then
            Ply:StripWeapon("weapon_mu_magnum")
        end
    end,
    DoPlayerDeath = function(Ply, Attacker)
        if IsValid(Attacker) and Attacker:IsMurderer() then return false end
    end,
    PlayerDeath = function(Ply, Attacker)
        if IsValid(Attacker) and Attacker:IsPlayer() and Attacker:IsMurderer() then
            PowerRounds.Chat("All", Color(255, 0, 0), Ply:Name() .. " é o novo assassino!")

            timer.Simple(0.5, function()
                Ply:Spawn()
                Ply:SetMurderer(true)
                Ply:CalculateSpeed()
                Ply:Give(Ply:GetKnife())
                local attackerKnife = Attacker:GetKnife()
                Attacker:SetMurderer(false)
                Attacker:CalculateSpeed()

                if Attacker:HasWeapon(attackerKnife) then
                    Attacker:StripWeapon(attackerKnife)
                end

                for _, ent in pairs(ents.FindByClass(attackerKnife)) do
                    ent:Remove()
                end
            end)
        end

        return false
    end,
    SetRandomMurderer = function()
        local NextMurderer = {}

        for _, v in pairs(PowerRounds.Players(2)) do
            if v:IsMurderer() then
                for _, ent in pairs(ents.FindByClass(v:GetKnife())) do
                    ent:Remove()
                end

                v:SetMurderer(false)
                v:Kill()
                local playerpos = v:GetPos()
                util.ScreenShake(playerpos, 5, 5, 1.5, 200)
                local vPoint = playerpos + Vector(0, 0, 10)
                local effectdata = EffectData()
                effectdata:SetStart(vPoint)
                effectdata:SetOrigin(vPoint)
                effectdata:SetScale(1)
                util.Effect("HelicopterMegaBomb", effectdata)
                v:EmitSound(Sound("ambient/explosions/explode_4.wav"))
            else
                table.insert(NextMurderer, v)
            end
        end

        if #NextMurderer > 1 then
            local Ply = NextMurderer[math.random(1, #NextMurderer)]
            Ply:SetMurderer(true)
            Ply:Give(Ply:GetKnife())
            Ply:CalculateSpeed()
            PowerRounds.Chat("All", Color(255, 0, 0), "O tempo acabou e " .. Ply:Name() .. " virou o novo assassino!")
            timer.Start("PowerRoundsTimer_TagChangeMurderer10")
            timer.Start("PowerRoundsTimer_TagChangeMurderer3")
            timer.Start("PowerRoundsTimer_TagChangeMurderer2")
            timer.Start("PowerRoundsTimer_TagChangeMurderer1")
            timer.Start("PowerRoundsTimer_TagChangeMurderer")
        end
    end,
    PlayerUpdate = function(Ply)
        local alivePlayers = PowerRounds.Players(2, Ply)

        if #alivePlayers < 2 then
            if IsValid(alivePlayers[1]) then
                local points = 250
                PowerRounds.Chat("All", "<hsv>" .. alivePlayers[1]:Name() .. " venceu a rodada e levou " .. points .. " " .. PS.Config.PointsName .. "!</hsv>")
                alivePlayers[1]:PS_GivePoints(points)
                alivePlayers[1]:PS_Notify("Você ganhou ", points, " ", PS.Config.PointsName, " por vencer o power round!")
            end

            PowerRounds.EndRound(PR_WIN_GOOD, alivePlayers[1])
        end
    end,
    SHOOK_CanPlayerSuicide = function(Ply) return not Ply:IsMurderer() end,
    STIMER_20_TagChangeMurderer10 = function()
        PowerRounds.Chat("All", Color(255, 255, 0), "O tempo de etiqueta acabará em 10 segundos...")
    end,
    STIMER_27_TagChangeMurderer3 = function()
        PowerRounds.Chat("All", Color(255, 153, 0), "O tempo de etiqueta acabará em 3 segundos...")
    end,
    STIMER_28_TagChangeMurderer2 = function()
        PowerRounds.Chat("All", Color(255, 153, 0), "O tempo de etiqueta acabará em 2 segundos...")
    end,
    STIMER_29_TagChangeMurderer1 = function()
        PowerRounds.Chat("All", Color(255, 0, 0), "O tempo de etiqueta acabará em 1 segundo...")
    end,
    STIMER_30_TagChangeMurderer = function()
        PowerRounds.CurrentPR.SetRandomMurderer()
    end,
    SupressMurderTimer = true
})

PowerRounds.AddRound({
    Name = "Infecção zumbi",
    Gamemode = "Murder",
    Description = "Quando o assassino esfaqueia alguem, este se torna um assassino também. Todos os inocentes ganharão armas em 10 segundos.",
    CustomRoundEnd = true,
    PlayersStart = function(Ply)
        if Ply:HasWeapon("weapon_mu_magnum") then
            Ply:StripWeapon("weapon_mu_magnum")
        end

        if Ply:IsMurderer() then
            PowerRounds.CurrentPR.SetZombieModel(Ply)
        end

        timer.Simple(20, function()
            if IsValid(Ply) and not Ply:IsMurderer() then
                Ply:Give("weapon_mu_magnum")
            end
        end)
    end,
    PlayerDeath = function(Ply, Attacker)
        if Ply:IsMurderer() then
            Ply:SetMurderer(false)

            return false
        elseif IsValid(Attacker) and Attacker:IsPlayer() and Attacker:IsMurderer() then
            timer.Simple(0.5, function()
                Ply:Spawn()
                Ply:SetMurderer(true)
                Ply:CalculateSpeed()
                Ply:Give(Ply:GetKnife())
                PowerRounds.CurrentPR.SetZombieModel(Ply)
            end)

            return false
        end
    end,
    PlayerUpdate = function(Ply)
        local alivePlayers = PowerRounds.Players(2, Ply)
        local anyMurderer
        local murderers = 0
        local bystanders = 0

        for _, v in ipairs(alivePlayers) do
            if v:IsMurderer() then
                murderers = murderers + 1
                anyMurderer = v
            else
                bystanders = bystanders + 1
            end
        end

        if murderers == 0 then
            PowerRounds.EndRound(PR_WIN_GOOD, alivePlayers[1])
        elseif bystanders == 0 then
            PowerRounds.EndRound(PR_WIN_BAD, anyMurderer)
        end
    end,
    SetZombieModel = function(Ply)
        local zombieModels = {"models/player/soldier_stripped.mdl", "models/player/corpse1.mdl", "models/player/charple.mdl", "models/player/zombie_classic.mdl", "models/player/zombie_fast.mdl", "models/player/zombie_soldier.mdl"}

        timer.Simple(0.5, function()
            if IsValid(Ply) then
                Ply:SetModel(table.Random(zombieModels))
            end
        end)
    end,
    SHOOK_PlayerShouldTakeDamage = function(Ply, Attacker)
        local murderKillingMurder = Ply:IsMurderer() and IsValid(Attacker) and Attacker:IsPlayer() and Attacker:IsMurderer()

        return not murderKillingMurder
    end
})

PowerRounds.AddRound({
    Name = "Infecção zoio",
    Gamemode = "Murder",
    Description = "Quando um zoio marreta alguem, este se torna um zoio também. Todos os inocentes ganharão armas em 10 segundos.",
    CustomRoundEnd = true,
    PlayersStart = function(Ply)
        if Ply:IsMurderer() then
            PowerRounds.CurrentPR.SetZoioModel(Ply)

            if Ply:HasWeapon(Ply:GetKnife()) then
                Ply:StripWeapon(Ply:GetKnife())
            end

            Ply:Give("marreta_do_zoio")
        elseif Ply:HasWeapon("weapon_mu_magnum") then
            Ply:StripWeapon("weapon_mu_magnum")
        end

        timer.Simple(20, function()
            if IsValid(Ply) and not Ply:IsMurderer() then
                Ply:Give("weapon_mu_magnum")
            end
        end)
    end,
    PlayerDeath = function(Ply, Attacker)
        if Ply:IsMurderer() then
            Ply:SetMurderer(false)

            return false
        elseif IsValid(Attacker) and Attacker:IsPlayer() and Attacker:IsMurderer() then
            timer.Simple(0.5, function()
                Ply:Spawn()
                Ply:SetMurderer(true)
                Ply:CalculateSpeed()
		if Ply:HasWeapon(Ply:GetKnife()) then
                    Ply:StripWeapon(Ply:GetKnife())
                end
                Ply:Give("marreta_do_zoio")
                PowerRounds.CurrentPR.SetZoioModel(Ply)
            end)

            return false
        end
    end,
    PlayerUpdate = function(Ply)
        local alivePlayers = PowerRounds.Players(2, Ply)
        local anyMurderer
        local murderers = 0
        local bystanders = 0

        for _, v in ipairs(alivePlayers) do
            if v:IsMurderer() then
                murderers = murderers + 1
                anyMurderer = v
            else
                bystanders = bystanders + 1
            end
        end

        if murderers == 0 then
            PowerRounds.EndRound(PR_WIN_GOOD, alivePlayers[1])
        elseif bystanders == 0 then
            PowerRounds.EndRound(PR_WIN_BAD, anyMurderer)
        end
    end,
    SetZoioModel = function(Ply)
        timer.Simple(0.5, function()
            if IsValid(Ply) then
                Ply:SetModel("models/eversonzoio/eversonzoio.mdl")
            end
        end)
    end,
    SHOOK_PlayerShouldTakeDamage = function(Ply, Attacker)
        local murderKillingMurder = Ply:IsMurderer() and IsValid(Attacker) and Attacker:IsPlayer() and Attacker:IsMurderer()

        return not murderKillingMurder
    end
})

PowerRounds.AddRound({
    Name = "Duplo perigo",
    Gamemode = "Murder",
    Description = "Existem 2 assassinos a solta!",
    ServerStart = function()
        local murderer = GAMEMODE:GetMurderer()
        local anotherMurderer = table.Random(PowerRounds.Players(2, murderer))
        anotherMurderer:SetMurderer(true)
        anotherMurderer:CalculateSpeed()
        anotherMurderer:Give(anotherMurderer:GetKnife())
        murderer:SetNWEntity("OtherMurderer", anotherMurderer)
        anotherMurderer:SetNWEntity("OtherMurderer", murderer)
    end,
    RunCondition = function() return #team.GetPlayers(2) > 10 end,
    CHOOK_PreDrawMurderHalos = function(Add)
        local client = LocalPlayer()
        local ply = client:Alive() and client or client:GetObserverTarget()
        local otherMurderer = ply:GetNWEntity("OtherMurderer")

        if IsValid(otherMurderer) and otherMurderer:Alive() then
            Add({
                {
                    ent = otherMurderer,
                    color = 1
                }
            }, {Color(220, 0, 0)}, 5, 5, 5, true, false)
        end
    end,
    SHOOK_PlayerShouldTakeDamage = function(Ply, Attacker)
        local murderKillingMurder = Ply:IsMurderer() and IsValid(Attacker) and Attacker:IsPlayer() and Attacker:IsMurderer()

        return not murderKillingMurder
    end
})

PowerRounds.AddRound({
    Name = "Comunicação localizada",
    Gamemode = "Murder",
    Description = "Só as pessoas próximas poderão lhe escutar.",
    ServerStart = function()
        RunConsoleCommand("mu_localchat", "1")
    end,
    ServerEnd = function()
        RunConsoleCommand("mu_localchat", "0")
    end
})

PowerRounds.AddRound({
    Name = "Recompensa pela cabeça",
    Gamemode = "Murder",
    Description = "Você só pode matar a pessoa destinada ou quem está tentando te matar. O ultimo em pé vence.",
    CustomRoundEnd = true,
    PlayerCanPickupWeapon = function() return true end,
    PlayerDeath = function(Ply, Attacker)
        if IsValid(Attacker) and Attacker:IsPlayer() then
            PowerRounds.CurrentPR.SetNewBounty(Attacker)
        end
    end,
    PlayersStart = function(Ply)
        Ply:SetMurderer(false)
        Ply:CalculateSpeed()

        if Ply:HasWeapon(Ply:GetKnife()) then
            Ply:StripWeapon(Ply:GetKnife())
        end

        Ply:Give("weapon_mu_magnum")
        PowerRounds.CurrentPR.SetNewBounty(Ply)
    end,
    SetNewBounty = function(Ply)
        local bounty = table.Random(PowerRounds.Players(2, Ply))
        Ply:SetNWEntity("Bounty", bounty)
        local ct = ChatText()

        ct:AddPart({
            text = "Você deve matar o "
        })

        ct:AddPart({
            text = bounty:GetBystanderName(),
            color = bounty:GetPlayerColor():ToColor()
        })

        ct:Send(Ply)
    end,
    PlayersEnd = function(Ply)
        Ply:SetNWEntity("Bounty", nil)
    end,
    PlayerUpdate = function(Ply)
        local alivePlayers = PowerRounds.Players(2, Ply)

        if #alivePlayers < 2 then
            if IsValid(alivePlayers[1]) then
                local points = 250
                PowerRounds.Chat("All", "<hsv>" .. alivePlayers[1]:Name() .. " venceu a rodada e levou " .. points .. " " .. PS.Config.PointsName .. "!</hsv>")
                alivePlayers[1]:PS_GivePoints(points)
                alivePlayers[1]:PS_Notify("Você ganhou ", points, " ", PS.Config.PointsName, " por vencer o power round!")
            end

            PowerRounds.EndRound(PR_WIN_GOOD, alivePlayers[1])
        else
            timer.Simple(0.5, function()
                if PowerRounds.CurrentPR and PowerRounds.CurrentPR.SetNewBounty then
                    for k, v in ipairs(alivePlayers) do
                        if IsValid(v) then
                            local bounty = v:GetNWEntity("Bounty")

                            if not IsValid(bounty) or not bounty:Alive() then
                                PowerRounds.CurrentPR.SetNewBounty(v)
                            end
                        end
                    end
                end
            end)
        end
    end,
    HUDPaint = function(h, w)
        local client = LocalPlayer()
        local ply = client:Alive() and client or client:GetObserverTarget()
        local entity = IsValid(ply) and ply:IsPlayer() and ply:GetNWEntity("Bounty")

        if IsValid(entity) then
            local text = "Você deve matar:"
            THEME:DrawShadowText(text, "PowerRoundsNextFont", PowerRounds.NextPos.W + 1, PowerRounds.NextPos.H + 34 + 1, color_white, PowerRounds.NextPos.TextAllignW, PowerRounds.NextPos.TextAllignH)
            THEME:DrawShadowText(entity:GetBystanderName(), "PowerRoundsNextFont", 210, PowerRounds.NextPos.H + 34 + 1, entity:GetPlayerColor():ToColor(), PowerRounds.NextPos.TextAllignW, PowerRounds.NextPos.TextAllignH)
        end
    end,
    SHOOK_PlayerShouldTakeDamage = function(Ply, Attacker)
        if IsValid(Attacker) and Attacker:IsPlayer() then
            local attackerBounty = Attacker:GetNWEntity("Bounty")
            local playerBounty = Ply:GetNWEntity("Bounty")

            return attackerBounty == Ply or playerBounty == Attacker
        end

        return true
    end,
    AllowRDM = true
})

PowerRounds.DoneRounds = true -- Don't touch this!

-- DO NOT edit anything further than this, if you don't know what you are doing!!
--[[ /Settings ]]
if CLIENT then
    surface.CreateFont("PowerRoundsDescriptionFont", {
        font = PowerRounds.DescriptionFont,
        size = PowerRounds.DescriptionSize,
        weight = 500
    })

    surface.CreateFont("PowerRoundsNameFont", {
        font = PowerRounds.NameFont,
        size = PowerRounds.NameSize,
        weight = 500
    })

    surface.CreateFont("PowerRoundsNextFont", {
        font = PowerRounds.NextFont,
        size = PowerRounds.NextSize,
        weight = 500
    })

    surface.CreateFont("PowerRoundsMenu20", {
        font = PowerRounds.MenuFont,
        size = 20,
        weight = 500
    })

    surface.CreateFont("PowerRoundsMenu30", {
        font = PowerRounds.MenuFont,
        size = 30,
        weight = 600
    })

    surface.CreateFont("PowerRoundsMenu22", {
        font = PowerRounds.MenuFont,
        size = 22,
        weight = 500
    })
end
