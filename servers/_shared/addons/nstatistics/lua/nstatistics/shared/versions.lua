local versionsMeta = {}

local function compare(l, r)
	for i = 1, 3 do
		local a = tonumber(l[i])
		local b = tonumber(r[i])

		if a > b then
			return 1
		elseif a < b then
			return -1
		end
	end

	return 0
end

function versionsMeta:__eq(to)
	return compare(self, to) == 0
end

function versionsMeta:__lt(to)
	return compare(self, to) == -1
end

function versionsMeta:__le(to)
	return compare(self, to) ~= 1
end

function versionsMeta:__tostring()
	return table.concat(self.Data, ".")
end

function versionsMeta:__index(key)
	return self.Data[key]
end

function NSTATISTICS.CreateVersionObj(a, b, c)
	if isstring(a) then
		local tbl = string.Explode(".", a)

		a = tbl[1]
		b = tbl[2]
		c = tbl[3]
	end

	local tbl = setmetatable({}, versionsMeta)
	tbl.Data = {
		tonumber(a) or 0,
		tonumber(b) or 0,
		tonumber(c) or 0
	}

	return tbl
end
