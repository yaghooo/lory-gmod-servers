GM.RoundStage = 0
GM.LootCollected = 0
GM.RoundSettings = {}

if GAMEMODE then
    GM.RoundStage = GAMEMODE.RoundStage
    GM.LootCollected = GAMEMODE.LootCollected
    GM.RoundSettings = GAMEMODE.RoundSettings
end

function GM:GetRound()
    return self.RoundStage or 0
end

net.Receive("SetRound", function(length)
    local r = net.ReadUInt(8)
    local start = net.ReadDouble()
    GAMEMODE.RoundStage = r
    GAMEMODE.RoundStart = start
    GAMEMODE.RoundSettings = {}
    local settings = net.ReadBool()

    if settings then
        GAMEMODE.RoundSettings.AdminPanelAllowed = net.ReadBool()
        GAMEMODE.RoundSettings.ShowSpectateInfo = net.ReadBool()
    end

    if r == 1 then
        timer.Simple(0.2, function()
            local client = LocalPlayer()
            local pitch = math.random(70, 140)

            if IsValid(client) then
                client:EmitSound("ambient/creatures/town_child_scream1.wav", 100, pitch)
                collectgarbage()
            end
        end)

        GAMEMODE.LootCollected = 0
    end
end)

net.Receive("DeclareWinner", function(length)
    local table_insert = table.insert
    local data = {}
    data.reason = net.ReadUInt(4)
    data.murderer = net.ReadEntity()
    data.murdererColor = net.ReadVector():ToColor()
    data.murdererName = net.ReadString()
    data.collectedLoot = {}

    while net.ReadBool() do
        local t = {}
        t.player = net.ReadEntity()

        if IsValid(t.player) then
            t.playerName = t.player:Nick()
        end

        t.playerColor = net.ReadVector():ToColor()
        t.playerBystanderName = net.ReadString()
        table_insert(data.collectedLoot, t)
    end

    GAMEMODE:DisplayEndRoundBoard(data)
    local pitch = math.random(80, 120)

    if IsValid(LocalPlayer()) then
        LocalPlayer():EmitSound("ambient/alarms/warningbell1.wav", 100, pitch)
    end
end)

net.Receive("GrabLoot", function(length)
    GAMEMODE.LootCollected = net.ReadUInt(32)
end)

net.Receive("SetLoot", function(length)
    GAMEMODE.LootCollected = net.ReadUInt(32)
end)