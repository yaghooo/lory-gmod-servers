include("pointshop/providers/interface.lua")
local provider = {}

local function executeQuery(callback, query, ...)
    local replacedQuery = string.format(query, ...)

    mysql.Query(replacedQuery, function(result)
        if result == false then
            error("Error in query: " .. query)
        end

        if callback then
            callback(result)
        end
    end)
end

-- POINTS
local POINTS_TABLE_NAME = "pointshop_points"

function provider:GetPoints(sid64, callback)
    local query = [[SELECT points FROM `%s` WHERE sid64 = '%s' LIMIT 1]]

    executeQuery(function(result)
        callback(result and result[1] and tonumber(result[1]["points"]) or 0)
    end, query, POINTS_TABLE_NAME, sid64)
end

function provider:SetPoints(sid64, points)
    local query = [[
        INSERT IGNORE INTO `%s` VALUES ('%s', 0);
        UPDATE `%s` SET points = %s WHERE sid64 = '%s'
    ]]
    executeQuery(nil, query, POINTS_TABLE_NAME, sid64, POINTS_TABLE_NAME, points, sid64)
end

function provider:GivePoints(sid64, points)
    local query = [[
        INSERT IGNORE INTO `%s` VALUES ('%s', 0);
        UPDATE `%s` SET points = points + %s WHERE sid64 = '%s'
    ]]
    executeQuery(nil, query, POINTS_TABLE_NAME, sid64, POINTS_TABLE_NAME, points, sid64)
end

function provider:TakePoints(sid64, points)
    local query = [[
        INSERT IGNORE INTO `%s` VALUES ('%s', 0);
        UPDATE `%s` SET points = points - %s WHERE sid64 = '%s'
    ]]
    executeQuery(nil, query, POINTS_TABLE_NAME, sid64, POINTS_TABLE_NAME, points, sid64)
end

-- ITEMS
local ITEMS_TABLE_NAME = "pointshop_items"

function provider:GetItems(sid64, callback)
    local query = [[SELECT * FROM `%s` WHERE sid64 = '%s']]
    executeQuery(function(result)
        callback(result or {})
    end, query, ITEMS_TABLE_NAME, sid64)
end

function provider:GiveItem(sid64, item_id)
    local query = [[INSERT INTO `%s`(sid64, item_id) VALUES('%s', %s)]]
    executeQuery(nil, query, ITEMS_TABLE_NAME, sid64, sql.SQLStr(item_id))
end

function provider:SetItemModifiers(sid64, item_id, modifiers)
    local query = [[UPDATE `%s` SET modifiers = %s WHERE sid64 = '%s' AND item_id = %s]]
    executeQuery(nil, query, ITEMS_TABLE_NAME, sql.SQLStr(modifiers), sid64, sql.SQLStr(item_id))
end

function provider:SetItemEquipped(sid64, item_id, equipped)
    local query = [[UPDATE `%s` SET equipped = %s WHERE sid64 = '%s' AND item_id = %s]]
    executeQuery(nil, query, ITEMS_TABLE_NAME, equipped, sid64, sql.SQLStr(item_id))
end

function provider:TakeItem(sid64, item_id)
    local query = [[
        DELETE FROM `%s` WHERE sid64 = '%s' AND item_id = %s LIMIT 1
    ]]
    executeQuery(nil, query, ITEMS_TABLE_NAME, sid64, sql.SQLStr(item_id))
end

function provider:GetItemsStats(callback)
    local query = [[
        SELECT item_id, COUNT(*) as total, COUNT(case when equipped = 1 then 1 else NULL end) as equipped FROM `%s` GROUP BY item_id
    ]]

    executeQuery(function(result)
        callback(result)
    end, query, ITEMS_TABLE_NAME)
end

PS.DataProvider = provider