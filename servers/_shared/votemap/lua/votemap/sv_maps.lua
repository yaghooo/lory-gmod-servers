VOTEMAP.MapCooldown = 8

function VOTEMAP:InitializeMaps()
    self.Maps = {}
    self.AvailableMaps = {}
    local lastPlayedMapsJson = file.Read("votemap/played_maps.json")
    local lastPlayedMaps = lastPlayedMapsJson and util.JSONToTable(lastPlayedMapsJson) or {}

    while #lastPlayedMaps > self.MapCooldown do
        table.remove(lastPlayedMaps, 1)
    end

    local currentMap = game.GetMap()

    for k, map in ipairs(ulx.votemaps) do
        local error = nil

        if table.HasValue(lastPlayedMaps, map) then
            error = "Jogado recentemente"
        elseif map == currentMap then
            error = "Mapa atual"
        else
            table.insert(self.AvailableMaps, map)
        end

        table.insert(self.Maps, {
            map = map,
            error = error
        })
    end

    table.insert(lastPlayedMaps, currentMap)
    file.Write("votemap/played_maps.json", util.TableToJSON(lastPlayedMaps))
end

function VOTEMAP:GetMaps()
    return self.Maps
end

function VOTEMAP:GetAvailableMaps()
    return self.AvailableMaps
end

timer.Simple(1, function()
    VOTEMAP:InitializeMaps()
end)
