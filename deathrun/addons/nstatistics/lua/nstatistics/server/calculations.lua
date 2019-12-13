local IsSaving = {}

function NSTATISTICS.CalculateType(type, year, month, day)
	local statistic = NSTATISTICS.Statistics[type]

	NSTATISTICS.Provider.IsCalculated(
		type,
		year,
		month,
		day,
		function(calculated)
			if not calculated then
				local id = type .. "_" .. NSTATISTICS.DateToStr(year, month, day)

				if not IsSaving[id] then
					IsSaving[id] = true

					NSTATISTICS.Provider.ReadRawInfo(
						statistic.ForPlayers,
						type,
						nil,
						{
							year = year,
							month = month,
							day = day,
							hour = 0
						},
						{
							year = year,
							month = month,
							day = day,
							hour = 24
						},
						function(data)
							if table.Count(data) > 0 then
								NSTATISTICS.Provider.WriteCalculatedData(
									type,
									statistic.Calculation(data),
									year,
									month,
									day,
									function()
										IsSaving[id] = false
									end
								)
							else
								IsSaving[id] = false
							end
						end
					)
				end
			end
		end
	)
end

function NSTATISTICS.Calculate(year, month, day)
	if NSTATISTICS.Provider.SaveAll then
		NSTATISTICS.Provider.SaveAll()
	end

	for name, v in pairs(NSTATISTICS.Statistics) do
		NSTATISTICS.CalculateType(name, year, month, day)
	end
end

function NSTATISTICS.CompletePastDatesType(type)
	local checked = {}

	NSTATISTICS.Provider.GetRawDataDates(
		type,
		function(dates)
			local time = os.time()

			local year = NSTATISTICS.GetYear(time)
			local month = NSTATISTICS.GetMonth(time)
			local day = NSTATISTICS.GetDay(time)

			for _, v in pairs(dates) do
				local str = NSTATISTICS.DateToStr(v.year, v.month, v.day)

				if (year ~= v.year or month ~= v.month or day ~= v.day) and not checked[str] then
					NSTATISTICS.Provider.IsCalculated(
						type,
						v.year,
						v.month,
						v.day,
						function(calculated)
							if not calculated then
								NSTATISTICS.CalculateType(type, v.year, v.month, v.day)
							end
						end
					)

					checked[str] = true
				end
			end
		end
	)
end

function NSTATISTICS.CompletePastDates()
	for name, v in pairs(NSTATISTICS.Statistics) do
		NSTATISTICS.CompletePastDatesType(name)
	end
end

NSTATISTICS.Calculations = {}

function NSTATISTICS.Calculations.Average(data)
	local sum = 0
	local num = 0

	for _, tbl in pairs(data) do
		for _, v in pairs(tbl) do
			sum = sum + v
			num = num + 1
		end
	end

	return {sum / math.max(num, 1)}
end

function NSTATISTICS.Calculations.Num(data)
	local counts = {}

	for _, tbl in pairs(data) do
		for _, v in pairs(tbl) do
			counts[v] = (counts[v] or 0) + 1
		end
	end

	return counts
end

function NSTATISTICS.Calculations.NumValue(data)
	local newdata = {}

	for _, tbl in pairs(data) do
		for _, json in pairs(tbl) do
			local values = util.JSONToTable(json)

			if values then
				for k, v in pairs(values) do
					newdata[k] = (newdata[k] or 0) + (tonumber(v) or 0)
				end
			end
		end
	end

	return newdata
end

function NSTATISTICS.Calculations.Count(data)
	local count = 0

	for _, tbl in pairs(data) do
		for _, v in pairs(tbl) do
			count = count + 1
		end
	end

	return {count}
end

function NSTATISTICS.Calculations.NumToPercent(data)
	local newdata = table.Copy(data)

	for _, tbl in pairs(newdata) do
		local sum = 0

		for k, v in pairs(tbl.data) do
			sum = sum + v
		end

		for k, v in pairs(tbl.data) do
			tbl.data[k] = math.Round((v / sum) * 100, 2)
		end
	end

	return newdata
end

NSTATISTICS.ConcatenateCalculations = {}

function NSTATISTICS.ConcatenateCalculations.Average(data)
	return NSTATISTICS.Calculations.Average(data)
end

function NSTATISTICS.ConcatenateCalculations.Num(data)
	local counts = {}

	for _, tbl in pairs(data) do
		for k, v in pairs(tbl) do
			counts[k] = (counts[k] or 0) + v
		end
	end

	return counts
end

function NSTATISTICS.ConcatenateCalculations.Count(data)
	return NSTATISTICS.Calculations.Count(data)
end

NSTATISTICS.Collisions = {}

function NSTATISTICS.Collisions.None(tbl)
	return tbl
end

function NSTATISTICS.Collisions.Average(tbl)
	for id, note in pairs(tbl) do
		local sum = 0

		for _, v in pairs(note) do
			sum = sum + v
		end

		tbl[id] = {sum / math.max(#note, 1)}
	end

	return tbl
end

function NSTATISTICS.Collisions.GetFirst(tbl)
	for k, note in pairs(tbl) do
		tbl[k] = {note[1]}
	end

	return tbl
end

function NSTATISTICS.Collisions.Sum(tbl)
	for id, note in pairs(tbl) do
		local sum = 0

		for _, v in pairs(note) do
			sum = sum + v
		end

		tbl[id] = {sum}
	end

	return tbl
end

function NSTATISTICS.RemoveOldStatistics()
	local time = NSTATISTICS.StrToTime(NSTATISTICS.config.RemoveStatistics)

	if time ~= 0 then
		NSTATISTICS.Provider.RemoveStatistics(nil, NSTATISTICS.GetDateWithHours(os.time() - time))
	end
end

hook.Add(
	"NStatistics_DayIsAboutToChange",
	"NStatistics_Calculation",
	function()
		local time = os.time()

		local year = NSTATISTICS.GetYear(time)
		local month = NSTATISTICS.GetMonth(time)
		local day = NSTATISTICS.GetDay(time)

		NSTATISTICS.Calculate(year, month, day)

		NSTATISTICS.RemoveOldStatistics()
	end
)

timer.Simple(
	0,
	function()
		if not NSTATISTICS.StatisticsCompleted then
			NSTATISTICS.CompletePastDates()
			NSTATISTICS.RemoveOldStatistics()

			NSTATISTICS.StatisticsCompleted = true
		end
	end
)
