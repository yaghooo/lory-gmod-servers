local provider = {}

local function executeQuery(query, ...)
    local replacedQuery = string.format(query, ...)
    local result = sql.Query(replacedQuery)

    if result == false then
        error("Error in query: " .. query .. " ~ Error: " .. sql.LastError())
    end

    return result
end

-- POINTS
local POINTS_TABLE_NAME = "pointshop_points"
executeQuery([[CREATE TABLE IF NOT EXISTS `%s` (
    `sid64` STRING PRIMARY KEY,
    `points` INTEGER
)]], POINTS_TABLE_NAME)

function provider:GetPoints(sid64, callback)
    local query = [[SELECT points FROM `%s` WHERE sid64 = '%s' LIMIT 1]]
    local result = executeQuery(query, POINTS_TABLE_NAME, sid64)

    callback(result and result[1] and tonumber(result[1]["points"]) or 0)
end

function provider:SetPoints(sid64, points)
    local query = [[
        INSERT OR IGNORE INTO `%s` VALUES ('%s', 0);
        UPDATE `%s` SET points = %s WHERE sid64 = '%s'
    ]]
    executeQuery(query, POINTS_TABLE_NAME, sid64, POINTS_TABLE_NAME, points, sid64)
end

function provider:GivePoints(sid64, points)
    local query = [[
        INSERT OR IGNORE INTO `%s` VALUES ('%s', 0);
        UPDATE `%s` SET points = points + %s WHERE sid64 = '%s'
    ]]
    executeQuery(query, POINTS_TABLE_NAME, sid64, POINTS_TABLE_NAME, points, sid64)
end

function provider:TakePoints(sid64, points)
    local query = [[
        INSERT OR IGNORE INTO `%s` VALUES ('%s', 0);
        UPDATE `%s` SET points = points - %s WHERE sid64 = '%s'
    ]]
    executeQuery(query, POINTS_TABLE_NAME, sid64, POINTS_TABLE_NAME, points, sid64)
end

-- ITEMS
local ITEMS_TABLE_NAME = "pointshop_items"
executeQuery([[CREATE TABLE IF NOT EXISTS `%s` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `sid64` STRING,
    `item_id` STRING,
    `modifiers` STRING,
    `equipped` BOOLEAN
)]], ITEMS_TABLE_NAME)

function provider:GetItems(sid64, callback)
    local query = [[SELECT * FROM `%s` WHERE sid64 = '%s']]
    local result = executeQuery(query, ITEMS_TABLE_NAME, sid64)

    callback(result or {})
end

function provider:GiveItem(sid64, item_id)
    local query = [[INSERT INTO `%s`(sid64, item_id) VALUES('%s', %s)]]
    executeQuery(query, ITEMS_TABLE_NAME, sid64, sql.SQLStr(item_id))
end

function provider:SetItemModifiers(sid64, item_id, modifiers)
    local query = [[UPDATE `%s` SET modifiers = %s WHERE sid64 = '%s' AND item_id = %s]]
    executeQuery(query, ITEMS_TABLE_NAME, sql.SQLStr(modifiers), sid64, sql.SQLStr(item_id))
end

function provider:SetItemEquipped(sid64, item_id, equipped)
    local query = [[UPDATE `%s` SET equipped = %s WHERE sid64 = '%s' AND item_id = %s]]
    executeQuery(query, ITEMS_TABLE_NAME, equipped, sid64, sql.SQLStr(item_id))
end

function provider:TakeItem(sid64, item_id)
    local query = [[
        DELETE FROM `%s` WHERE id = (
            SELECT id FROM `%s` WHERE sid64 = '%s' AND item_id = %s LIMIT 1
        )
    ]]
    executeQuery(query, ITEMS_TABLE_NAME, ITEMS_TABLE_NAME, sid64, sql.SQLStr(item_id))
end

function provider:GetItemsStats(callback)
    local query = [[
        SELECT item_id, COUNT(*) as total, COUNT(case when equipped = 1 then 1 else NULL end) as equipped FROM `%s` GROUP BY item_id
    ]]
    callback(executeQuery(query, ITEMS_TABLE_NAME))
end

-- MARKETPLACE
local MARKETPLACE_TABLE_NAME = "pointshop_marketplace"
executeQuery([[CREATE TABLE IF NOT EXISTS `%s` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `seller_sid64` STRING,
    `buyer_sid64` STRING,
    `item_id` STRING,
    `date` INTEGER,
    `price` INTEGER
)]], MARKETPLACE_TABLE_NAME)

function provider:CreateAnnounce(sid64, item_id, price)
    local query = [[INSERT INTO `%s` (seller_sid64, item_id, date, price) VALUES('%s', '%s', '%s', '%s')]]
    executeQuery(query, MARKETPLACE_TABLE_NAME, sid64, item_id, os.time(), price)
end

function provider:SetAnnounceBuyer(id, buyer_sid64)
    local query = [[UPDATE `%s` SET buyer_sid64 = '%s' WHERE id = '%s']]
    executeQuery(query, MARKETPLACE_TABLE_NAME, buyer_sid64, id)
end

function provider:GetBuyableAnnounces(callback)
    local query = [[SELECT id, item_id, price, seller_sid64 FROM `%s` WHERE buyer_sid64 IS NULL]]
    callback(executeQuery(query, MARKETPLACE_TABLE_NAME) or {})
end

PS.DataProvider = provider