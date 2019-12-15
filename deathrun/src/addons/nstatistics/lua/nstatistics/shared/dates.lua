local function GetDateFormat(date, format)
	if date.year then
		format = string.Replace(format, "y", NSTATISTICS.CompleteNumber(date.year, 4))
	end

	if date.month then
		format = string.Replace(format, "m", NSTATISTICS.CompleteNumber(date.month, 2))
	end

	if date.day then
		format = string.Replace(format, "d", NSTATISTICS.CompleteNumber(date.day, 2))
	end

	if date.hour then
		format = string.Replace(format, "h", NSTATISTICS.CompleteNumber(date.hour, 2))
	end

	return format
end

function NSTATISTICS.GetDateFormat(date)
	local format

	if date.year and date.month and date.day and date.hour then
		format = NSTATISTICS.config.DateFormatYMDH
	elseif date.year and date.month and date.day then
		format = NSTATISTICS.config.DateFormatYMD
	elseif date.year and date.month then
		format = NSTATISTICS.config.DateFormatYM
	else
		format = NSTATISTICS.config.DateFormatY
	end

	return GetDateFormat(date, format)
end

function NSTATISTICS.StrToTime(str)
	local StrTime = 0

	for w in string.gmatch(str, "%d+%a") do
		local char = w[#w]
		local num = tonumber(string.sub(w, 1, #w - 1)) or 0

		if char == "d" then
			StrTime = StrTime + num
		elseif char == "m" then
			StrTime = StrTime + num * 30
		elseif char == "y" then
			StrTime = StrTime + num * 365
		end
	end

	return StrTime * 86400
end

function NSTATISTICS.GetYear(time)
	return tonumber(os.date("%Y", time))
end

function NSTATISTICS.GetMonth(time)
	return tonumber(os.date("%m", time))
end

function NSTATISTICS.GetDay(time)
	return tonumber(os.date("%d", time))
end

function NSTATISTICS.GetHour(time)
	return tonumber(os.date("%H", time))
end

function NSTATISTICS.GetDateWithHours(time)
	return {
		year = NSTATISTICS.GetYear(time),
		month = NSTATISTICS.GetMonth(time),
		day = NSTATISTICS.GetDay(time),
		hour = NSTATISTICS.GetHour(time)
	}
end

function NSTATISTICS.GetDate(time)
	return {
		year = NSTATISTICS.GetYear(time),
		month = NSTATISTICS.GetMonth(time),
		day = NSTATISTICS.GetDay(time)
	}
end

function NSTATISTICS.GetCurDate()
	return NSTATISTICS.GetDate(os.time())
end

function NSTATISTICS.GetCurDateWithHours()
	return NSTATISTICS.GetDateWithHours(os.time())
end

function NSTATISTICS.IsDateBetween(startdate, enddate, date)
	local time = os.time(date)

	if startdate and time < os.time(startdate) then
		return false
	end

	if enddate and time > os.time(enddate) then
		return false
	end

	return true
end

function NSTATISTICS.GetDayStartTime(time)
	local date = NSTATISTICS.GetDate(time or os.time())

	return {
		year = date.year,
		month = date.month,
		day = date.day,
		hour = 0
	}
end

function NSTATISTICS.GetDayEndTime(time)
	local date = NSTATISTICS.GetDate(time or os.time())

	return {
		year = date.year,
		month = date.month,
		day = date.day,
		hour = 24
	}
end

function NSTATISTICS.GetDayEnds(date)
	local startdate
	local enddate

	if date.hour then
		startdate = date
		enddate = date
	else
		startdate = table.Copy(date)
		startdate.hour = 0

		enddate = table.Copy(date)
		enddate.hour = 24
	end

	return startdate, enddate
end

function NSTATISTICS.DateToStr(year, month, day, hours)
	local tbl = {}

	if year then
		table.insert(tbl, NSTATISTICS.CompleteNumber(year, 4))
	end

	if month then
		table.insert(tbl, NSTATISTICS.CompleteNumber(month, 2))
	end

	if day then
		table.insert(tbl, NSTATISTICS.CompleteNumber(day, 2))
	end

	if hours then
		table.insert(tbl, NSTATISTICS.CompleteNumber(hours, 2))
	end

	return table.concat(tbl, "_")
end

function NSTATISTICS.StrToDate(str)
	return NSTATISTICS.TableToDate(string.Explode("_", str))
end

function NSTATISTICS.TableToDate(tbl)
	return {
		year = tonumber(tbl[1]),
		month = tonumber(tbl[2]),
		day = tonumber(tbl[3]),
		hour = tonumber(tbl[4])
	}
end
