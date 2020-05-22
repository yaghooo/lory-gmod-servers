require("mysqloo")

mysql = {}

local mysql_hostname = CreateConVar("mysql_hostname", "localhost", FCVAR_NONE, "MySql hostname")
local mysql_username = CreateConVar("mysql_username", "root", FCVAR_NONE, "MySql Username")
local mysql_password = CreateConVar("mysql_password", "", FCVAR_NONE, "MySql Password")
local mysql_database = CreateConVar("mysql_database", "lory", FCVAR_NONE, "MySql Database")
local mysql_port = 3306 -- Your MySQL port. Most likely is 3306.

local db = mysqloo.connect(mysql_hostname:GetString(), mysql_username:GetString(), mysql_password:GetString(), mysql_database:GetString(), mysql_port)

function db:onConnected()
    MsgC("MySQL: Connected!")
end

function db:onConnectionFailed(err)
    MsgC(Color(255, 0, 0), "MySQL: Connection Failed, please check your settings: ", err)
end

db:connect()

function mysql.Query(query, callback)
    local q = db:query(query)

    function q:onSuccess(data)
        callback(data)
    end

    function q:onError(err, sql)
        if db:status() ~= mysqloo.DATABASE_CONNECTED then
            db:connect()
            db:wait()

            if db:status() ~= mysqloo.DATABASE_CONNECTED then
                ErrorNoHalt("Re-connection to database server failed.")
                callback(false)

                return
            end
        end

        MsgC("MySQL: Query Failed: ", err, "(", sql, ")")
        q:start()
    end

    q:start()
end