local format = "%.2f FPS"

NSTATISTICS.AddStatistic(
	{
		Title = "FPS",
		Name = "fps",
		Beautifier = nil,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = format,
		Legend = nil,
		ShowKey = false,
		MinChartY = nil,
		ModifyFilterRawData = function(filter)
			return (filter:TextFormatToFilter(format) or filter):GetNumbers():NotExact()
		end
	}
)

local FrameTimeSum = 0
local times = 0

hook.Add(
	"Think",
	"NStatistics_GetFrameTime",
	function()
		if system.HasFocus() then
			FrameTimeSum = FrameTimeSum + FrameTime()
			times = times + 1
		end
	end
)

timer.Create(
	"NStatistics_SendFrameTime",
	300,
	0,
	function()
		if times ~= 0 then
			NSTATISTICS.SendStatisticToServer("fps", {math.Clamp(times / FrameTimeSum, 0, 300)})

			times = 0
			FrameTimeSum = 0
		end
	end
)
