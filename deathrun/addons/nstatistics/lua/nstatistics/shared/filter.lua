local filterMeta = {}

function filterMeta:Modify(isRaw, statistics)
	local copy = table.Copy(self)

	if statistics and statistics.ModifyFilterRawData then
		copy = statistics.ModifyFilterRawData(copy)
	end

	return copy
end

local function find(filter, callback, ...)
	local copy = table.Copy(filter)

	for _, v in pairs({...}) do
		local parsed = callback(copy.Filter, v)

		if parsed then
			copy.Filter = parsed
			return copy
		end
	end

	return false
end

function filterMeta:PhrasesFormatToFilter(...)
	return find(
		self,
		function(filter, v)
			return NSTATISTICS.ParsePhrase(filter, v)
		end,
		...
	)
end

function filterMeta:TextFormatToFilter(...)
	return find(
		self,
		function(filter, v)
			return NSTATISTICS.ParseText(filter, v)
		end,
		...
	)
end

function filterMeta:FindLike(texts)
	local copy = table.Copy(self)

	if self.Filter ~= "" then
		local filterLower = string.lower(copy.Filter)

		for k, v in pairs(texts) do
			local lower = string.lower(v)

			if copy.ExactMatch and lower == filterLower or not copy.ExactMatch and string.find(lower, filterLower, 1, true) then
				local new = NSTATISTICS.CreateFilter(k, false, true)
				copy = copy:Merge(new)
			end
		end
	end

	return copy
end

function filterMeta:FindLikePhrases(phrases)
	local new = {}

	for k, v in pairs(phrases) do
		new[k] = NSTATISTICS.GetPhrase(v)
	end

	return self:FindLike(new)
end

function filterMeta:GetNumbers(int)
	local copy = table.Copy(self)
	local newFilter = copy.Filter

	if not int then
		newFilter = string.Replace(newFilter, ",", ".")
	end

	newFilter = string.gsub(newFilter, int and "[^%d]" or "[^%d%.]", "")

	copy.Filter = newFilter
	return copy
end

function filterMeta:Merge(...)
	local copy = table.Copy(self)

	for _, v in pairs({...}) do
		table.insert(copy.AlternativeFilters, v)
	end

	return copy
end

function filterMeta:DisableFilter()
	self.Disabled = true
	return self
end

function filterMeta:NotExact()
	local copy = table.Copy(self)
	copy.ExactMatch = false

	return copy
end

function filterMeta:Exact()
	local copy = table.Copy(self)
	copy.ExactMatch = true

	return copy
end

function filterMeta:NotContain()
	local copy = table.Copy(self)
	copy.NotContain = true

	return copy
end

function filterMeta:Contain()
	local copy = table.Copy(self)
	copy.NotContain = false

	return copy
end

filterMeta.__index = filterMeta

function NSTATISTICS.SetFilterMeta(tbl)
	return setmetatable(tbl, filterMeta)
end

function NSTATISTICS.CreateFilter(filterString, notContain, exactMatch, alternativeFilters, disabled)
	local filterTbl = {
		Filter = filterString or "",
		AlternativeFilters = alternativeFilters or {},
		NotContain = notContain or false,
		ExactMatch = exactMatch or false,
		ShouldBeFiltered = ShouldBeFiltered,
		Disabled = disabled
	}

	return NSTATISTICS.SetFilterMeta(filterTbl)
end

if SERVER then
	function NSTATISTICS.ShouldBeFiltered(filterTable, data)
		if not filterTable or not filterTable.Filter or filterTable.Disabled then
			return false
		end

		local filter = string.lower(filterTable.Filter)
		data = string.lower(data)

		local filtered

		if filterTable.ExactMatch then
			filtered = data ~= filter
		else
			local s, e = string.find(data, filter, 1, true)
			filtered = s == nil
		end

		for _, v in pairs(filterTable.AlternativeFilters) do
			local copy = table.Copy(v)

			if filterTable.NotContain then
				copy.NotContain = false
			end

			local alternative = NSTATISTICS.ShouldBeFiltered(copy, data)

			if not alternative then
				filtered = false
				break
			end
		end

		return filterTable.NotContain and not filtered or filtered
	end

	function NSTATISTICS.FilterToSQL(filterTable, field, escape)
		if not field or not filterTable or not filterTable.Filter or filterTable.Disabled then
			return false
		end

		local copy = table.Copy(filterTable)
		field = "LOWER(" .. field .. ")"

		local filter = escape(string.lower(copy.Filter))

		if filter == "" and not copy.ExactMatch then
			copy.ExactMatch = true
		end

		local SQL = "("

		local notContain = copy.NotContain
		if notContain then
			SQL = SQL .. "NOT("
		end

		if copy.ExactMatch then
			SQL = SQL .. field .. " = '" .. filter .. "'"
		else
			-- 16688742
			SQL = SQL .. field .. " LIKE '%" .. filter .. "%'"
		end

		for _, v in pairs(copy.AlternativeFilters) do
			if copy.NotContain then
				v.NotContain = false
			end

			local AlternativeSQL = NSTATISTICS.FilterToSQL(v, field, escape)
			if AlternativeSQL and AlternativeSQL ~= "" then
				SQL = SQL .. " OR " .. AlternativeSQL
			end
		end

		if notContain then
			SQL = SQL .. ")"
		end

		SQL = SQL .. ")"

		return SQL
	end
end
