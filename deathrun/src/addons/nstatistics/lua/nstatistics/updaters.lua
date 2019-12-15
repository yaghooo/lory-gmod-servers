timer.Simple(
	0,
	function()
		local updatingName = ""

		local function updatingNotificationStart(name)
			updatingName = name
			NSTATISTICS.PrintConsole("Updating " .. name .. " statistics...")
		end

		local function updatingNotificationEnd()
			NSTATISTICS.PrintConsole("Updating " .. updatingName .. " statistics complete")
			updatingName = ""
		end

		-- If I want to change some data
		local updaters = {
			{
				version = NSTATISTICS.CreateVersionObj(1, 2, 0),
				updater = function()
					-- REMOVE SPACES

					updatingNotificationStart("hardware")

					local hwtypes = {
						"videocard",
						"videocard_manufacturer",
						"ram"
					}

					for _, type in pairs(hwtypes) do
						NSTATISTICS.Provider.ManuallyUpdateStatistics(
							type,
							nil,
							nil,
							function(data)
								local tbl = util.JSONToTable(data)
								local ret = {}

								if tbl then
									for k, v in pairs(tbl) do
										local trimmed = string.Trim(k)

										if trimmed ~= "" then
											ret[trimmed] = v
										end
									end
								end

								if table.Count(ret) > 0 then
									return util.TableToJSON(ret)
								else
									return true
								end
							end
						)

						NSTATISTICS.Provider.ManuallyUpdateData(
							type,
							nil,
							nil,
							function(data)
								local trimmed = string.Trim(data)

								if trimmed ~= "" then
									return trimmed
								else
									return true
								end
							end
						)
					end

					updatingNotificationEnd()

					-- REMOVE EMPTY GEOLOCATION FIELDS

					updatingNotificationStart("localtion")

					local iptypes = {
						"country",
						"region",
						"city"
					}

					for _, type in pairs(iptypes) do
						NSTATISTICS.Provider.ManuallyUpdateStatistics(
							type,
							nil,
							nil,
							function(data)
								local tbl = util.JSONToTable(data)
								local ret = {}

								if tbl then
									for k, v in pairs(tbl) do
										local trimmed = string.Trim(k)

										if trimmed ~= "" and trimmed ~= "_1_" then
											ret[trimmed] = v
										end
									end
								end

								if table.Count(ret) > 0 then
									return util.TableToJSON(ret)
								else
									return true
								end
							end
						)

						NSTATISTICS.Provider.ManuallyUpdateData(
							type,
							nil,
							nil,
							function(data)
								local trimmed = string.Trim(data)

								if trimmed ~= "" and trimmed ~= "_1_" then
									return trimmed
								else
									return true
								end
							end
						)
					end

					updatingNotificationEnd()
				end
			}
		}

		function NSTATISTICS.UpdateDataVersion(from)
			local last = from
			local updated = 0

			for k, v in pairs(updaters) do
				if last < v.version then
					updated = updated + 1

					NSTATISTICS.PrintConsole("Updating from " .. tostring(last) .. " to " .. tostring(v.version))
					local success, err = pcall(v.updater)

					if not success then
						NSTATISTICS.Error("Error has occurred, updating aborted:\n" .. err .. "\n")
					end

					last = v.version
				end
			end

			if updated > 0 then
				NSTATISTICS.PrintConsole("Updated successfully, steps: " .. updated)
			end
		end

		if file.Exists("nstatistics/lastversion.txt", "DATA") then
			local last = file.Read("nstatistics/lastversion.txt", "DATA")

			if last and last ~= "" then
				NSTATISTICS.LastVersion = NSTATISTICS.CreateVersionObj(last)
			end
		end

		function NSTATISTICS.SetLastVersion(version)
			file.Write("nstatistics/lastversion.txt", tostring(version))
			NSTATISTICS.LastVersion = version
		end

		file.CreateDir("nstatistics")

		if not NSTATISTICS.LastVersion then
			NSTATISTICS.SetLastVersion(NSTATISTICS.Version)
		else
			if NSTATISTICS.LastVersion < NSTATISTICS.Version then
				NSTATISTICS.UpdateDataVersion(NSTATISTICS.LastVersion)
				NSTATISTICS.SetLastVersion(NSTATISTICS.Version)
			end
		end

		-- TIMER
	end
)
