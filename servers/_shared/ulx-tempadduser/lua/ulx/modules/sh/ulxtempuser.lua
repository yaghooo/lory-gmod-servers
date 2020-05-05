local CATEGORY_NAME = "User Management"

if not file.Exists("ulx", "DATA") then
    file.CreateDir("ulx")
end

if not file.Exists("ulx/tempuserdata", "DATA") then
    file.CreateDir("ulx/tempuserdata")
end

ulx.tempuser_group_names = {}

local function updateNames()
    table.Empty(ulx.tempuser_group_names)

    for group_name, _ in pairs(ULib.ucl.groups) do
        table.insert(ulx.tempuser_group_names, group_name)
    end
end

hook.Add(ULib.HOOK_UCLCHANGED, "ULXTempAddUesrGroupNamesUpdate", updateNames)
updateNames()

hook.Add("PlayerSay", "CheckPlayerVip", function(ply, text, team)
    if text == "!meuvip" then
        timer.Simple(0.1, function()
            if ply:GetUserGroup() == "vip" then
                local SID = ply:SteamID64()

                if file.Exists("ulx/tempuserdata/" .. SID .. ".txt", "DATA") then
                    local todecode = file.Read("ulx/tempuserdata/" .. SID .. ".txt", "DATA")
                    local tbl = string.Explode("|", todecode)
                    local exptime = tonumber(tbl[1] - os.time())
                    ply:ChatPrint("Seu vip acabará em " .. math.Round(exptime / 60 / 60 / 24) .. " dias.")
                else
                    ply:ChatPrint("Parábens! Seu vip é permanente!")
                end
            else
                ply:ChatPrint("Ops! Você ainda não é vip. :(")
            end
        end)
    end
end)

function ulx.CheckExpiration(pl)
    local SID = pl:SteamID64()

    if file.Exists("ulx/tempuserdata/" .. SID .. ".txt", "DATA") then
        local todecode = file.Read("ulx/tempuserdata/" .. SID .. ".txt", "DATA")
        local tbl = string.Explode("|", todecode)
        local exptime = tonumber(tbl[1])
        local rgroup = tbl[2]

        if os.time() >= exptime then
            ulx.ExpireGroupChange(pl, rgroup)
        else
            if os.time() + 3600 >= exptime then
                timer.Create("ULXGroupExpire_" .. SID, exptime - os.time(), 1, function()
                    ulx.ExpireGroupChange(pl, rgroup)
                end)
            end
        end
    end
end

hook.Add("PlayerAuthed", "CheckExpiration", ulx.CheckExpiration)

function ulx.PeriodicExpirationCheck()
    if CLIENT then return end

    for _, pl in pairs(player.GetAll()) do
        if IsValid(pl) and pl:IsConnected() then
            ulx.CheckExpiration(pl)
        end
    end
end

timer.Create("ulx_periodicexpirationcheck", 3600, 0, ulx.PeriodicExpirationCheck)

function ulx.ExpireGroupChange(pl, group)
    if not IsValid(pl) or not pl:IsConnected() then return end
    local SID = pl:SteamID64()

    if group == "user" then
        ULib.ucl.removeUser(pl:SteamID())
    else
        ULib.ucl.addUser(pl:SteamID(), _, _, group)
    end

    ulx.fancyLogAdmin(pl, "#A teve seu VIP expirado.", group)
    timer.Remove("ULXGroupExpire_" .. SID)

    if file.Exists("ulx/tempuserdata/" .. SID .. ".txt", "DATA") then
        file.Delete("ulx/tempuserdata/" .. SID .. ".txt")
    end
end

function ulx.CreateExpiration(pl, exp_time, return_group)
    local SID = pl:SteamID64()
    local exp_time_global = (exp_time * 60) + os.time()
    local tbl = {}
    tbl["exptime"] = exp_time_global
    tbl["returngroup"] = return_group
    local toencode = exp_time_global .. "|" .. return_group
    file.Write("ulx/tempuserdata/" .. SID .. ".txt", toencode)
end

function ulx.CreateExpirationByID(id, exp_time, return_group)
    local SID = id
    local exp_time_global = (exp_time * 60) + os.time()
    local tbl = {}
    tbl["exptime"] = exp_time_global
    tbl["returngroup"] = return_group
    local toencode = exp_time_global .. "|" .. return_group
    file.Write("ulx/tempuserdata/" .. SID .. ".txt", toencode)
end

function ulx.tempadduser(calling_ply, target_ply, group_name, exp_time, return_group_name)
    group_name = group_name:lower()
    return_group_name = return_group_name:lower()
    local userInfo = ULib.ucl.authed[target_ply:UniqueID()]
    local id = ULib.ucl.getUserRegisteredID(target_ply)

    if not id then
        id = target_ply:SteamID()
    end

    ULib.ucl.addUser(id, userInfo.allow, userInfo.deny, group_name)
    ulx.CreateExpiration(target_ply, exp_time, return_group_name)

    if exp_time <= 30 then
        timer.Create("ULXGroupExpire_" .. target_ply:SteamID64(), exp_time * 60, 1, function()
            ulx.ExpireGroupChange(target_ply, return_group_name)
        end)
    end
end

local tempadduser = ulx.command(CATEGORY_NAME, "ulx tempadduser", ulx.tempadduser)

tempadduser:addParam{
    type = ULib.cmds.PlayerArg
}

tempadduser:addParam{
    type = ULib.cmds.StringArg,
    completes = ulx.tempuser_group_names,
    hint = "Group to place user in temporarily",
    error = "invalid group '%s' specified",
ULib.cmds.restrictToCompletes
}

tempadduser:addParam{
    type = ULib.cmds.NumArg,
    hint = "Time (Minutes)"
}

tempadduser:addParam{
    type = ULib.cmds.StringArg,
    completes = ulx.tempuser_group_names,
    hint = "Group to place user in after time expires",
    error = "invalid group '%s' specified",
ULib.cmds.restrictToCompletes
}

tempadduser:defaultAccess(ULib.ACCESS_SUPERADMIN)
tempadduser:help("Add a user to specified group for a specified time.")

function ulx.tempadduserid64(calling_ply, target_id, group_name, exp_time, return_group_name)
    group_name = group_name:lower()
    return_group_name = return_group_name:lower()

    if not target_id then
        print("Invalid SteamID64")
        return
    end

    local target_ply = player.GetBySteamID64(target_id)

    if target_ply then
        local userInfo = ULib.ucl.authed[target_ply:UniqueID()]
        local id = ULib.ucl.getUserRegisteredID(target_ply)

        if not id then
            id = target_ply:SteamID()
        end

        ULib.ucl.addUser(id, userInfo.allow, userInfo.deny, group_name)
        ulx.fancyLogAdmin(calling_ply, "#A added #T to group #s for " .. exp_time .. " minutes.", target_ply, group_name)
        ulx.CreateExpiration(target_ply, exp_time, return_group_name)

        if exp_time <= 30 then
            timer.Create("ULXGroupExpire_" .. target_ply:SteamID64(), exp_time * 60, 1, function()
                ulx.ExpireGroupChange(target_ply, return_group_name)
            end)
        end
    else
        ULib.ucl.addUser(util.SteamIDFrom64(target_id), userInfo.allow, userInfo.deny, group_name)
        ulx.fancyLogAdmin(calling_ply, "#A added " .. target_id .. " to group #s for " .. exp_time .. " minutes.", group_name)
        ulx.CreateExpirationByID(target_id, exp_time, return_group_name)
    end
end

local tempadduserid64 = ulx.command(CATEGORY_NAME, "ulx tempadduserid", ulx.tempadduserid64)

tempadduserid64:addParam{
    type = ULib.cmds.NumArg
}

tempadduserid64:addParam{
    type = ULib.cmds.StringArg,
    completes = ulx.tempuser_group_names,
    hint = "Group to place user in temporarily",
    error = "invalid group '%s' specified",
ULib.cmds.restrictToCompletes
}

tempadduserid64:addParam{
    type = ULib.cmds.NumArg,
    hint = "Time (Minutes)"
}

tempadduserid64:addParam{
    type = ULib.cmds.StringArg,
    completes = ulx.tempuser_group_names,
    hint = "Group to place user in after time expires",
    error = "invalid group '%s' specified",
ULib.cmds.restrictToCompletes
}

tempadduserid64:defaultAccess(ULib.ACCESS_SUPERADMIN)
tempadduserid64:help("Add a user by SteamID64 to specified group for a specified time.")