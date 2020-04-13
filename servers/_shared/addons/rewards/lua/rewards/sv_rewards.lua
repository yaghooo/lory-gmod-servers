function REWARDS:LoadRewards()
    self.Prizes = {}

    local files, _ = file.Find("rewards/prizes/*.lua", "LUA")
    for _, name in pairs(files) do
        PRIZE = {}
        PRIZE.Id = string.gsub(string.lower(name), ".lua", "")

        include("rewards/prizes/" .. name)
        resource.AddSingleFile("materials/rewards/" .. PRIZE.Image .. ".png")

        self.Prizes[PRIZE.Id] = PRIZE
        PRIZE = nil
    end
end

function REWARDS:SendPrizes(ply)
    local prizes = table.Copy(self.Prizes)
    for k, v in pairs(prizes) do
        v.Status = v:GetStatus(ply)
    end

    net.Start("rewards_prizes")
        net.WriteString(util.TableToJSON(prizes))
    net.Send(ply)
end

function REWARDS:GivePrize(ply, prizeId)
    local prize = self.Prizes[prizeId]
    local currentStatus = prize:GetStatus(ply)

    if currentStatus == "RESGATAR" then
        prize:Redeem(ply)
    end

    self:SendPrizes(ply)
end

function REWARDS:GetRandomLoot(ply)
    local lootables = {}

    for _, v in pairs(PS.Items) do
        if v.Lootable then
            table.insert(lootables, v)
        end
    end

    local loot = table.Random(lootables)
    return loot
end

util.AddNetworkString("rewards_prizes")
util.AddNetworkString("rewards_redeem")

net.Receive("rewards_redeem", function(len, ply)
    local prizeId = net.ReadString()
    REWARDS:GivePrize(ply, prizeId)
end)

hook.Add("PlayerInitialSpawn", "GetUserRewards", function(ply)
    timer.Simple(5, function()
        if ply and IsValid(ply) then
            REWARDS:SendPrizes(ply)
        end
    end)
end)