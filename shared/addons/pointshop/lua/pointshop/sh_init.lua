PS = {}
PS.__index = PS
PS.Items = {}
PS.Categories = {}
PS.ClientsideModels = {}

function PS:ValidatePoints(points)
    if type(points) ~= "number" then
        error("Points should be of type number")
    end

    return points >= 0 and points or 0
end

-- Utils
function PS:FindCategoryByName(cat_name)
    for id, cat in pairs(self.Categories) do
        if cat.Name == cat_name then return cat end
    end

    return false
end

function PS:GetPointsText(points)
    local text = string.Comma(points) .. " "
    text = text .. (points == 1 and PS.Config.PointsName or PS.Config.PointsName .. "s")
    return text
end

-- Initialization
function PS:Initialize()
    if SERVER then
        self:LoadDataProvider()
        self:LoadSounds()
    end

    self:LoadMaterials()
    self:LoadItems()
end

-- Loading
function PS:LoadMaterials()
    local materials = {"money", "loading", "key", "case", "item_shadow"}
    self.Materials = {}

    for _, v in pairs(materials) do
        local materialDir = "pointshop/" .. v .. ".png"

        if SERVER then
            resource.AddFile("materials/" .. materialDir)
        else
            self.Materials[v] = Material(materialDir)
        end
    end
end

function PS:LoadItems()
    local _, dirs = file.Find("pointshop/items/*", "LUA")

    for _, category in pairs(dirs) do
        local f, _ = file.Find("pointshop/items/" .. category .. "/__category.lua", "LUA")

        if #f > 0 then
            CATEGORY = {}
            CATEGORY.Name = ""
            CATEGORY.Icon = ""
            CATEGORY.Order = 0
            CATEGORY.AllowedEquipped = -1
            CATEGORY.AllowedUserGroups = {}

            if SERVER then
                AddCSLuaFile("pointshop/items/" .. category .. "/__category.lua")
            end

            include("pointshop/items/" .. category .. "/__category.lua")

            if not PS.Categories[category] then
                PS.Categories[category] = CATEGORY
            end

            local files, _ = file.Find("pointshop/items/" .. category .. "/*.lua", "LUA")

            for _, name in pairs(files) do
                if name ~= "__category.lua" then
                    if SERVER then
                        AddCSLuaFile("pointshop/items/" .. category .. "/" .. name)
                    end

                    ITEM = {}
                    ITEM.__index = ITEM
                    ITEM.ID = string.gsub(string.lower(name), ".lua", "")
                    ITEM.Category = CATEGORY.Name
                    -- model and material are missing but there's no way around it, there's a check below anyway
                    ITEM.AdminOnly = false
                    ITEM.AllowedUserGroups = {} -- this will fail the #ITEM.AllowedUserGroups test and continue
                    ITEM.SingleUse = false
                    ITEM.NoPreview = false
                    ITEM.CanPlayerBuy = true
                    ITEM.CanPlayerSell = true
                    ITEM.CanPlayerEquip = true
                    ITEM.CanPlayerHolster = true
                    ITEM.ModifyClientsideModel = function(s, ply, model, pos, ang) return model, pos, ang end
                    include("pointshop/items/" .. category .. "/" .. name)

                    if not ITEM.Price and CATEGORY.GetPrice then
                        ITEM.Price = CATEGORY:GetPrice(ITEM)
                    end

                    if not ITEM.Name then
                        ErrorNoHalt("[POINTSHOP] Item missing name: " .. category .. "/" .. name .. "\n")
                    elseif not ITEM.Price then
                        ErrorNoHalt("[POINTSHOP] Item missing price: " .. category .. "/" .. name .. "\n")
                    elseif not ITEM.Model and (CLIENT and not ITEM.Material) and not ITEM.ImgurImage then
                        ErrorNoHalt("[POINTSHOP] Item missing model or material: " .. category .. "/" .. name .. "\n")
                    else
                        -- precache
                        if ITEM.Model then
                            util.PrecacheModel(ITEM.Model)
                        end

                        self.Items[ITEM.ID] = ITEM
                    end

                    ITEM = nil
                end
            end

            CATEGORY = nil
        end
    end
end