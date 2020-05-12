if not TeamSpawns then
    TeamSpawns = {}
    TeamSpawns["spawns"] = {}
end

function GM:LoadSpawns()
    for listName, spawnList in pairs(TeamSpawns) do
        local json = file.ReadDataAndContent("murder/" .. game.GetMap() .. "/" .. listName .. ".txt")

        if json then
            local tbl = util.JSONToTable(json)
            TeamSpawns[listName] = tbl
        end
    end
end

function GM:SaveSpawns()
    -- ensure the folders are there
    if not file.Exists("murder/", "DATA") then
        file.CreateDir("murder")
    end

    local mapName = game.GetMap()

    if not file.Exists("murder/" .. mapName .. "/", "DATA") then
        file.CreateDir("murder/" .. mapName)
    end

    -- JSON
    for listName, spawnList in pairs(TeamSpawns) do
        local json = util.TableToJSON(spawnList)
        file.Write("murder/" .. mapName .. "/" .. listName .. ".txt", json)
    end
end

local function getPosPrintString(pos, plyPos)
    return math.Round(pos.x) .. ", " .. math.Round(pos.y) .. ", " .. math.Round(pos.z) .. " " .. math.Round(pos:Distance(plyPos) / 12) .. "ft"
end

concommand.Add("mu_spawn_add", function(ply, com, args, full)
    if not ply:IsAdmin() then return end

    if #args < 1 then
        ply:ChatPrint("Too few args (spawnList)")

        return
    end

    local spawnList = TeamSpawns[args[1]]

    if not spawnList then
        ply:ChatPrint("Invalid list")

        return
    end

    table.insert(spawnList, ply:GetPos())
    ply:ChatPrint("Added " .. #spawnList .. ": " .. getPosPrintString(ply:GetPos(), ply:GetPos()))
    GAMEMODE:SaveSpawns()
end)

concommand.Add("mu_spawn_list", function(ply, com, args, full)
    if not ply:IsAdmin() then return end

    if #args < 1 then
        ply:ChatPrint("Too few args (spawnList)")

        return
    end

    local spawnList = TeamSpawns[args[1]]

    if not spawnList then
        ply:ChatPrint("Invalid list")

        return
    end

    ply:ChatPrint("SpawnList " .. args[1])

    for k, pos in pairs(spawnList) do
        ply:ChatPrint(k .. ": " .. getPosPrintString(pos, ply:GetPos()))
    end
end)

concommand.Add("mu_spawn_closest", function(ply, com, args, full)
    if not ply:IsAdmin() then return end

    if #args < 1 then
        ply:ChatPrint("Too few args (spawnList)")

        return
    end

    local spawnList = TeamSpawns[args[1]]

    if not spawnList then
        ply:ChatPrint("Invalid list")

        return
    end

    if #spawnList <= 0 then
        ply:ChatPrint("List is empty")

        return
    end

    local closest

    for k, pos in pairs(spawnList) do
        if spawnList[closest]:Distance(ply:GetPos()) > pos:Distance(ply:GetPos()) then
            closest = k
            break
        end
    end

    ply:ChatPrint(closest .. ": " .. getPosPrintString(spawnList[closest], ply:GetPos()))
end)

concommand.Add("mu_spawn_remove", function(ply, com, args, full)
    if not ply:IsAdmin() then return end

    if #args < 2 then
        ply:ChatPrint("Too few args (spawnList, key)")

        return
    end

    local spawnList = TeamSpawns[args[1]]

    if not spawnList then
        ply:ChatPrint("Invalid list")

        return
    end

    local key = tonumber(args[2]) or 0

    if not spawnList[key] then
        ply:ChatPrint("Invalid key, position inexists")

        return
    end

    local pos = spawnList[key]
    table.remove(spawnList, key)
    ply:ChatPrint("Remove " .. key .. ": " .. getPosPrintString(pos, ply:GetPos()))
    GAMEMODE:SaveSpawns()
end)
