timer.Simple(
	0,
	function()
		if file.Exists("nstatistics/language.txt", "DATA") then
			local curlang = file.Read("nstatistics/language.txt", "DATA")

			if curlang and curlang ~= "" then
				if NSTATISTICS.Languages[curlang] then
					NSTATISTICS.Language = curlang
				else
					NSTATISTICS.PrintConsole("Unsupported language: " .. curlang)
				end
			end
		end
	end
)

if not NSTATISTICS.Language then
	NSTATISTICS.Language = NSTATISTICS.config.DefaultLanguage
end

function NSTATISTICS.SetLanguage(lang)
	NSTATISTICS.Language = lang

	file.CreateDir("nstatistics")
	file.Write("nstatistics/language.txt", lang)

	NSTATISTICS.ReloadMenu()
end

local LastLang = ""

local function phrase(lang, key)
	if NSTATISTICS.Languages[lang] then
		LastLang = lang

		local phrase = NSTATISTICS.Languages[lang][key]
		return isstring(phrase) and phrase
	else
		return false
	end
end

function NSTATISTICS.GetUnformattedPhrase(key)
	return phrase(NSTATISTICS.Language, key) or phrase(NSTATISTICS.config.DefaultLanguage, key) or phrase("en", key)
end

function NSTATISTICS.GetPhrase(key, ...)
	-- For empty phrase
	if key == "" then
		return ""
	end

	local unformatted = NSTATISTICS.GetUnformattedPhrase(key)

	if unformatted then
		local success, str = pcall(string.format, unformatted, ...)

		if success then
			return str
		else
			NSTATISTICS.PrintConsole(
				"Error has occured while formatting phrase '" ..
					key ..
						"' in language '" .. LastLang .. "'. Check if you keep all specifiers that begin with %. Error: " .. str .. "\n"
			)
			return "Error"
		end
	else
		return "Missing text: " .. key
	end
end
