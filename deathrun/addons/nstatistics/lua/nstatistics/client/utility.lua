function NSTATISTICS.SplitJSONRawData(data)
	local new = {}

	for k, v in pairs(data) do
		local data = util.JSONToTable(v.data)
		v.data = nil

		if data then
			for sk, sv in pairs(data) do
				local copy = table.Copy(v)
				copy.data = sk .. ":  " .. NSTATISTICS.GetPhrase("MinutesShort", sv)

				table.insert(new, copy)
			end
		end
	end

	return new
end
