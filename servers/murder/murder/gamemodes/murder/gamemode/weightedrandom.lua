local WRandom = {}
WRandom.__index = WRandom

function WeightedRandom()
    local tab = {}
    tab.items = {}
    setmetatable(tab, WRandom)

    return tab
end

function WRandom:Add(weight, item)
    local t = {}
    t.weight = weight
    t.item = item
    table.insert(self.items, t)
end

function WRandom:Roll()
    local total = 0

    for _, item in pairs(self.items) do
        total = total + item.weight
    end

    local c = math.random(total - 1)
    local cur = 0

    for _, item in pairs(self.items) do
        cur = cur + item.weight
        if c < cur then return item.item end
    end
end