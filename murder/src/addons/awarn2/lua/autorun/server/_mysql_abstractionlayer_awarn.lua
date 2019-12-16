local debug = debug
local error = error
local ErrorNoHalt = ErrorNoHalt
local hook = hook
local include = include
local pairs = pairs
local require = require
local sql = sql
local string = string
local table = table
local timer = timer
local tostring = tostring
local GAMEMODE = GM or GAMEMODE
local _G = _G
local print = print
module("MySQLite_AWarn")

function isMySQL()
    return false
end

function begin()
    sql.Begin()
end

function commit(onFinished)
    sql.Commit()

    if onFinished then
        onFinished()
    end

    return
end

function queueQuery(sqlText, callback, errorCallback)
    query(sqlText, callback, errorCallback)
end

local function SQLiteQuery(sqlText, callback, errorCallback, queryValue)
    local lastError = sql.LastError()
    local Result = queryValue and sql.QueryValue(sqlText) or sql.Query(sqlText)

    if sql.LastError() and sql.LastError() ~= lastError then
        local err = sql.LastError()
        local supp = errorCallback and errorCallback(err, sqlText)

        if not supp then
            error(err .. " (" .. sqlText .. ")")
        end

        return
    end

    if callback then
        callback(Result)
    end

    return Result
end

function query(sqlText, callback, errorCallback)
    local qFunc = SQLiteQuery

    return qFunc(sqlText, callback, errorCallback, false)
end

function queryValue(sqlText, callback, errorCallback)
    local qFunc = SQLiteQuery

    return qFunc(sqlText, callback, errorCallback, true)
end

function SQLStr(str)
    local escape = sql.SQLStr

    return escape(str)
end

function tableExists(tbl, callback, errorCallback)
    local exists = sql.TableExists(tbl)
    callback(exists)

    return exists
end