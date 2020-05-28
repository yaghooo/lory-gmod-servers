GM.BystanderNameParts = {}

local function addPart(name, sex)
    local tab = {}
    tab.name = name
    tab.sex = sex
    table.insert(GM.BystanderNameParts, tab)
end

-- Don't add to this list, add names to data/murder/bystander_name_parts.txt
addPart("Alfa")
addPart("Bravo")
addPart("Charlie")
addPart("Delta")
addPart("Echo")
addPart("Foxtrot")
addPart("Golf")
addPart("Hotel")
addPart("India")
addPart("Juliett")
addPart("Kilo")
addPart("Lima")
addPart("Miko")
addPart("November")
addPart("Oscar")
addPart("Papa")
addPart("Quebec")
addPart("Romeo")
addPart("Sierra")
addPart("Tango")
addPart("Uniform")
addPart("Victor")
addPart("Whiskey")
addPart("X-ray")
addPart("Yankee")
addPart("Zulu")
local EntityMeta = FindMetaTable("Entity")

-- adds a name to the bystander parts generation table
function GM:AddBystanderNamePart(name, sex)
    name = tostring(name)

    if not name then
        error("arg 1(name) must be a string")
    end

    if sex ~= "male" and sex ~= "female" then
        sex = nil
    end

    local tab = {}
    tab.name = name
    tab.sex = sex
    table.insert(self.BystanderNameParts, tab)
end

function GM:GenerateName(sex)
    if #self.BystanderNameParts <= 0 then
        error("BystanderNameParts is not defined")

        return "error"
    end

    local tab = {}

    for _, v in pairs(self.BystanderNameParts) do
        if v.sex == sex or v.sex == nil then
            table.insert(tab, v.name)
        end
    end

    return table.Random(tab)
end

function EntityMeta:GenerateBystanderName()
    local name = GAMEMODE:GenerateName(self.ModelSex or "male")
    self:SetNWString("bystanderName", name)
    self.BystanderName = name
end

function EntityMeta:SetBystanderName(name)
    self:SetNWString("bystanderName", name)
    self.BystanderName = name
end

function EntityMeta:GetBystanderName()
    local name = self:GetNWString("bystanderName")

    return name ~= "" and name or "Bystander"
end

concommand.Add("mu_print_players", function(admin, com, args)
    if not admin:IsAdmin() then return end

    for _, ply in ipairs(player.GetAll()) do
        local c = ChatText()
        c:Add(ply:Nick())
        c:Add(" " .. ply:GetBystanderName(), ply:GetPlayerColor():ToColor())
        c:Add(" " .. ply:SteamID())
        c:Add(" " .. team.GetName(ply:Team()), team.GetColor(ply:Team()))
        c:Send(admin)
    end
end)