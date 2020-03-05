local provider = {}

local function executeQuery(query, ...)
    local replacedQuery = string.format(query, ...)
    local result = sql.Query(replacedQuery)

    if result == false then
        print("Error in query: " .. query)
        print("Error: " .. sql.LastError())
    end

    return result
end

-- POINTS
local POINTS_TABLE_NAME = "pointshop_points"
executeQuery("CREATE TABLE IF NOT EXISTS `%s` ( `sid64` STRING, `points` REAL, PRIMARY KEY(sid64) )", POINTS_TABLE_NAME)

function provider:GetPoints(sid64)
    local query = [[SELECT points FROM `%s` WHERE sid64 = '%s' LIMIT 1]]
    local result = executeQuery(query, POINTS_TABLE_NAME, sid64)
    return result[1] and result[1]["points"] or 0
end

function provider:SetPoints(sid64, points)
    local query = [[UPDATE `%s` SET points = '%s' WHERE sid64 = '%s']]
    executeQuery(query, POINTS_TABLE_NAME, points, sid64)
end

function provider:GivePoints(sid64, points)
    local query = [[UPDATE `%s` SET points = points + '%s' WHERE sid64 = '%s']]
    executeQuery(query, POINTS_TABLE_NAME, points, sid64)
end

function provider:TakePoints(sid64, points)
    local query = [[UPDATE `%s` SET points = points - '%s' WHERE sid64 = '%s']]
    executeQuery(query, POINTS_TABLE_NAME, points, sid64)
end

-- ITEMS
local ITEMS_TABLE_NAME = "pointshop_items"
executeQuery("CREATE TABLE IF NOT EXISTS `%s` ( `sid64` STRING, `item_id` STRING )", ITEMS_TABLE_NAME)

function provider:GetItems(sid64)
    local query = [[SELECT item_id FROM `%s` WHERE sid64 = '%s']]
    local result = executeQuery(query, ITEMS_TABLE_NAME, sid64)

    local items = {}

    if result and #result > 0 then
        for k, v in result do
            items[k] = result[k]["item_id"]
        end
    end

    return items
end

function provider:GiveItem(sid64, item_id)
    local query = [[INSERT INTO `%s` VALUES('%s', %s)]]
    executeQuery(query, ITEMS_TABLE_NAME, sid64, sql.SQLStr(item_id))
end

function provider:TakeItem(sid64, item_id)
    local query = [[DELETE FROM `%s` WHERE sid64 = '%s' AND item_id = %s]]
    executeQuery(query, ITEMS_TABLE_NAME, sid64, sql.SQLStr(item_id))
end

-- TRANSACTIONS
local TRANSACTIONS_TABLE_NAME = "pointshop_transactions"
executeQuery("CREATE TABLE IF NOT EXISTS `%s` ( `sid64` STRING, `action` STRING, `value` STRING, `thirdSid64` STRING )", TRANSACTIONS_TABLE_NAME)

function provider:AddTransaction(sid64, action, value, thirdSid64)
    local query = [[INSERT INTO `%s` VALUES('%s', '%s', %s, '%s')]]
    value = value and sql.SQLStr(value) or "NULL"
    executeQuery(query, TRANSACTIONS_TABLE_NAME, sid64, action, value, thirdSid64)
end

function provider:GetTransactions(sid64, quantity)
    local query = [[SELECT * FROM `%s` WHERE sid64 = '%s' LIMIT %s]]
    executeQuery(query, TRANSACTIONS_TABLE_NAME, sid64, quantity)
end

PS.DataProvider = provider