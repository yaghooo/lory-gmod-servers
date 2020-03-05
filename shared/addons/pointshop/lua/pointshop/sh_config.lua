PS.Config = {}

-- Edit below
PS.Config.CommunityName = "LORYSHOP"
PS.Config.DataProvider = "sqlite"
PS.Config.ShopKey = "F3" -- Any Uppercase key or blank to disable
PS.Config.ShopCommand = "" -- Console command to open the shop, set to blank to disable
PS.Config.ShopChatCommand = "!loja" -- Chat command to open the shop, set to blank to disable
PS.Config.NotifyOnJoin = true -- Should players be notified about opening the shop when they spawn?
PS.Config.LootChance = 0.03
PS.Config.CrateItemQuantity = 200
PS.Config.PointsOverTime = true -- Should players be given points over time?
PS.Config.PointsOverTimeDelay = 5 -- If so, how many minutes apart?
PS.Config.PointsOverTimeAmount = 250 -- And if so, how many points to give after the time?
PS.Config.AdminCanAccessAdminTab = false -- Can Admins access the Admin tab?
PS.Config.CanPlayersGiveItems = true
PS.Config.CanPlayersGivePoints = true -- Can players give points away to other players?
PS.Config.PointsName = "Judeu" -- What are the points called?
PS.Config.SortItemsBy = "Name" -- How are items sorted? Set to 'Price' to sort by price.

-- Edit below if you know what you're doing
PS.Config.CalculateBuyPrice = function(ply, item)
    return item.Price
end

PS.Config.CalculateSellPrice = function(ply, item)
    if item.Category == "Facas" or item.Category == "Caixas" then
        return math.Round(item.Price * 0.1)
    end

    return math.Round(item.Price * 0.50)
end