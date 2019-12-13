NSTATISTICS.Precisions = {}
NSTATISTICS.Precisions.Day = 0
NSTATISTICS.Precisions.Month = 1
NSTATISTICS.Precisions.Year = 2

-- Waiting for versions.lua
timer.Simple(
	0,
	function()
		NSTATISTICS.Version = NSTATISTICS.CreateVersionObj("1.2.1")
	end
)
