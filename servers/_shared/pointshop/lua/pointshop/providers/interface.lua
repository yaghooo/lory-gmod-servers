require("mysqloo")

mysql = {}

local mysql_hostname = "localhost" -- Your MySQL server address.
local mysql_username = "root" -- Your MySQL username.
local mysql_password = "" -- Your MySQL password.
local mysql_database = "lory" -- Your MySQL database.
local mysql_port = 3306 -- Your MySQL port. Most likely is 3306.

local db = mysqloo.connect(mysql_hostname, mysql_username, mysql_password, mysql_database, mysql_port)

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