function Initialize()
	json = dofile(SKIN:GetVariable('@') .. 'Dependencies\\json4lua\\json.lua')
	S_PATH_RESOURCES = SKIN:GetVariable('@')
	S_VDF_SERIALIZING_INDENTATION = ''
	T_SETTINGS = ReadSettings()
	if T_SETTINGS == nil then
		SKIN:Bang('[!SetOption StatusMessage Text "Load Settings.ini and save settings."][!UpdateMeterGroup Status][!ShowMeterGroup Status][!Redraw]')
		return
	end
	for i=1, tonumber(T_SETTINGS['slot_count']) do
		SKIN:Bang('[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightPlay.png"][!HideMeterGroup "SlotHighlight' .. i .. '"]')
	end
	N_LAUNCH_STATE = 0
	T_LAUNCH_STATES = {
		LAUNCH = 0,
		HIDE = 1,
		UNHIDE = 2
	}
	T_RECENTLY_LAUNCHED_GAME = nil
	N_SORT_STATE = 0 --0 = alphabetically, 1 = most recently played
	if T_SETTINGS['sortstate'] then
		N_SORT_STATE = tonumber(T_SETTINGS['sortstate']) - 1
		CycleSort()
	end
	S_SETTING_SLOT_COUNT = 'slot_count'
	N_SCROLL_INDEX = 1
	N_SCROLL_STEP = 1
	-- If GAME_KEYS values are changed, then they have to be copied to the GameKeys class in Enums.py.
	GAME_KEYS = {
		ARGUMENTS = "arguments",
		BANNER_ERROR = "bannererror",
		BANNER_PATH = "banner",
		BANNER_URL = "bannerurl",
		ERROR = "error",
		HIDDEN = "hidden",
		HOURS_LAST_TWO_WEEKS = "hourslast2weeks",
		HOURS_TOTAL = "hourstotal",
		INVALID_PATH = "invalidpatherror",
		LASTPLAYED = "lastplayed",
		NAME = "title",
		NOT_INSTALLED = "notinstalled",
		PATH = "path",
		PLATFORM = "platform",
		PROCESS = "process",
		TAGS = "tags"
	}
	-- If PLATFORM values are changed, then they have to be copied to the Platform class in Enums.py.
	PLATFORM = {
		STEAM = 0,
		STEAM_SHORTCUT = 1,
		GOG_GALAXY = 2,
		WINDOWS_SHORTCUT = 3,
		WINDOWS_URL_SHORTCUT = 4,
		BATTLENET = 5
	}
	PLATFORM_DESCRIPTION = {
		"Steam",
		"Steam",
		"GOG Galaxy",
		"",
		"",
		"Battle.net"
	}
	B_FORCE_TOOLBAR = false
	HideToolbar()
	B_REVERSE_SORT = false
	SKIN:Bang('[!HideMeter "ToolbarButtonSortReverseIndicator"]')
	if T_SETTINGS ~= nil then
		SKIN:Bang('[!SetOption StatusMessage Text "Initializing backend..."][!UpdateMeterGroup Status][!ShowMeterGroup Status][!Redraw]')
		SKIN:Bang('"#Python#" "#@#Backend\\GetGames.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"')
	else
		SKIN:Bang('[!SetOption StatusMessage Text "Failed to load settings..."][!UpdateMeterGroup Status][!ShowMeterGroup Status][!Redraw]')
	end
	N_LAST_DRAWN_SCROLL_INDEX = -1
end

-- Called once after Initialize() has been called. Runs Backend\GetGames.py.
function Update()
	if N_LAST_DRAWN_SCROLL_INDEX ~= N_SCROLL_INDEX then
		PopulateSlots()
		N_LAST_DRAWN_SCROLL_INDEX = N_SCROLL_INDEX
	end
end

-- Called by Backend\GetGames.py when it has successfully completed its task.
function Init()
	SKIN:Bang('[!HideMeterGroup Status]')
	local tGames = ReadGames()
	T_ALL_GAMES = {} -- all games found in 'games.json'
	T_FILTERED_GAMES = {} -- subset of T_ALL_GAMES
	T_HIDDEN_GAMES = {}
	T_NOT_INSTALLED_GAMES = {}
	for sKey, tTable in pairs(tGames) do
		if tTable[GAME_KEYS.HIDDEN] == true then
			table.insert(T_HIDDEN_GAMES, tTable)
		elseif tTable[GAME_KEYS.NOT_INSTALLED] == true then
			table.insert(T_NOT_INSTALLED_GAMES, tTable)
		else
			table.insert(T_ALL_GAMES, tTable)
		end
	end
	--T_FILTERED_GAMES = T_ALL_GAMES
	if T_ALL_GAMES ~= nil and #T_ALL_GAMES > 0 then
		FilterBy('')
	elseif T_NOT_INSTALLED_GAMES ~= nil and #T_NOT_INSTALLED_GAMES > 0 then
		FilterBy('installed:false')
	elseif T_HIDDEN_GAMES ~= nil and #T_HIDDEN_GAMES > 0 then
		FilterBy('hidden:true')
	else
		SKIN:Bang('[!SetOption StatusMessage Text "No games to display"][!UpdateMeterGroup Status][!ShowMeterGroup Status]')
	end
	PopulateSlots()
end

-- Utility
	function RecursiveTableSearch(atTable, asKey)
		for sKey, Value in pairs(atTable) do
			if sKey == asKey then
				return Value
			end
		end
		for sKey, Value in pairs(atTable) do
			if type(Value) == 'table' then
				local tResult = RecursiveTableSearch(Value, asKey)
				if tResult ~= nil then
					return tResult
				end
			end
		end
		return nil
	end

	function StartsWith(asString, asPrefix)
		if asString == nil or asPrefix == nil then
			return false
		end
		return asString:match('^(' .. asPrefix .. '.-)$') ~= nil
	end

	function EndsWith(asString, asSuffix)
		if asString == nil or asSuffix == nil then
			return false
		end
		return asString:match('^(.-' .. asSuffix .. ')$') ~= nil
	end

	function Trim(asString)
		return asString:match('^%s*(.-)%s*$')
	end

	function FileExists(asPath)
		local f = io.open(asPath, 'r')
		if f ~= nil then
			f:close()
			return true
		end
		return false
	end

	function ResourceExists(asPath)
		return FileExists(S_PATH_RESOURCES .. asPath)
	end

	function BannerExists(asPath)
		return FileExists(S_PATH_RESOURCES .. 'Banners\\' .. asPath)
	end

	function ReadJSON(asPath)
		local f = io.open(asPath, 'r')
		if f ~= nil then
			local json_string = f:read('*a')
			f:close()
			return json.decode(json_string)
		end
		return nil
	end

	function WriteJSON(asPath, atTable)
		local json_string = json.encode(atTable)
		if json_string == nil then
			return false
		end
		local f = io.open(asPath, 'w')
		if f ~= nil then
			f:write(json_string)
			f:close()
			return true
		end
		return false
	end

	function ReadGames()
		return ReadJSON(S_PATH_RESOURCES .. 'games.json')
	end

	function WriteGames()
		tTable = {}
		for i=1, #T_ALL_GAMES do
			table.insert(tTable, T_ALL_GAMES[i])
		end
		for i=1, #T_HIDDEN_GAMES do
			table.insert(tTable, T_HIDDEN_GAMES[i])
		end
		for i=1, #T_NOT_INSTALLED_GAMES do
			table.insert(tTable, T_NOT_INSTALLED_GAMES[i])
		end
		return WriteJSON(S_PATH_RESOURCES .. 'games.json', tTable)
	end

	function ReadSettings()
		return ReadJSON(S_PATH_RESOURCES .. 'settings.json')
	end

	function WriteSettings(atTable)
		return WriteJSON(S_PATH_RESOURCES .. 'settings.json', atTable)
	end

-- Slots
	function FilterBy(asPattern)
		if asPattern == '' then
			T_FILTERED_GAMES = ClearFilter(T_ALL_GAMES)
			Sort()
			PopulateSlots()
			return
		end
		local sort = true
		asPattern = asPattern:lower()
		if StartsWith(asPattern, '+') then
			T_FILTERED_GAMES, sort = Filter(T_FILTERED_GAMES, asPattern:sub(2))
		else
			T_FILTERED_GAMES, sort = Filter(T_ALL_GAMES, asPattern)
		end
		if sort then
			Sort()
		else
			N_SCROLL_INDEX = 1
		end
		PopulateSlots()
	end

	function FilterByTag(atTable, asPattern, asTag, asKey, abTrue)
		local tResult = {}
		asPattern = asPattern:sub(#asTag + 2)
		if StartsWith(asPattern, 't') then
			for i = 1, #atTable do
				if atTable[i][asKey] == abTrue then
					table.insert(tResult, atTable[i])
				end
			end
		elseif StartsWith(asPattern, 'f') then
			for i = 1, #atTable do
				if atTable[i][asKey] ~= abTrue then
					table.insert(tResult, atTable[i])
				end
			end
		else
			return tResult
		end
		return tResult
	end

	function Filter(atTable, asPattern)
		if atTable == nil then
			return
		end
		local tResult = {}
		if StartsWith(asPattern, 'steam:') then
			return FilterByTag(atTable, asPattern, 'steam', GAME_KEYS.PLATFORM, PLATFORM.STEAM), true
		elseif StartsWith(asPattern, 'galaxy:') then
			return FilterByTag(atTable, asPattern, 'galaxy', GAME_KEYS.PLATFORM, PLATFORM.GOG_GALAXY), true
		elseif StartsWith(asPattern, 'battlenet:') then
			return FilterByTag(atTable, asPattern, 'battlenet', GAME_KEYS.PLATFORM, PLATFORM.BATTLENET), true
		elseif StartsWith(asPattern, 'tags:') then
			asPattern = asPattern:sub(6)
			for i = 1, #atTable do
				if atTable[i][GAME_KEYS.TAGS] ~= nil then
					for sKey, sValue in pairs(atTable[i][GAME_KEYS.TAGS]) do
						if sValue:lower():find(asPattern) then
							table.insert(tResult, atTable[i])
							break
						end
					end
				end
			end
		elseif StartsWith(asPattern, 'installed:') then
			asPattern = asPattern:sub(11)
			if StartsWith(asPattern, 't') then
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResult, game)
				end
			elseif StartsWith(asPattern, 'f') then
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResult, game)
				end
			else
				return tResult, true
			end
		elseif StartsWith(asPattern, 'hidden:') then
			asPattern = asPattern:sub(8)
			if StartsWith(asPattern, 't') then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					table.insert(tResult, game)
				end
			elseif StartsWith(asPattern, 'f') then
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResult, game)
				end
			else
				return tResult, true
			end
		else
			if T_SETTINGS['fuzzy_search'] == true then
				local rankings = {}
				local perfectMatches = {}
				for i = 1, #atTable do
					score = FuzzySearch(asPattern, atTable[i][GAME_KEYS.NAME])
					if score > 0 then
						table.insert(rankings, {["score"]=score, ["game"]=atTable[i]})
					end
				end
				table.sort(rankings, SortRanking)
				--print("== " .. asPattern .. " ==") -- Debug
				for i, entry in ipairs(rankings) do
					--print(entry.score, entry.game[GAME_KEYS.NAME]) -- Debug
					table.insert(tResult, entry.game)
				end
				return tResult, false
			else
				for i = 1, #atTable do
					if atTable[i][GAME_KEYS.NAME]:lower():find(asPattern) then
						table.insert(tResult, atTable[i])
					end
				end
			end
		end
		return tResult, true
	end

	function SortRanking(aFirst, aSecond)
		--if aFirst.ranking == -1 or aFirst.ranking > aSecond.ranking then
		if aFirst.score > aSecond.score then
			return true
		elseif aFirst.score == aSecond.score then
			return SortAlphabetically(aFirst.game, aSecond.game)
		else
			return false
		end
	end

	function SplitStringIntoChars(aString)
		local characters = {}
		for char in aString:gmatch(".") do
			table.insert(characters, char)
		end
		return characters
	end

	function SplitStringIntoWords(aString)
		local words = {}
		for word in aString:gmatch("[^%s%p]*") do
			if word ~= nil and word ~= "" then
				table.insert(words, word)
			end
		end
		return words
	end

	function FuzzySearch(aPattern, aString)
		-- Case-insensitive fuzzy match that returns a score
		if aPattern == "" or aString == "" then
			return 0
		end
		-- Bonuses
		local bonusPerfectMatch = 50
		local bonusFirstMatch = 25
		local bonusMatch = 10
		local bonusMatchDistance = 10
		local bonusConsecutiveMatches = 10
		local bonusFirstWordMatch = 20
		-- Penalties
		local penaltyNotMatch = -5
		--
		local score = 0
		aPattern = aPattern:lower()
		aString = aString:lower()
		-- Pattern matches perfectly
		if aPattern == aString then
			score = score + bonusPerfectMatch
		end
		local patternCharacters = SplitStringIntoChars(aPattern)
		local stringChars = SplitStringIntoChars(aString)
		local stringWords = SplitStringIntoWords(aString)

		function match_string(aPatternCharacters, aStringToMatch)
			local matchIndex = aStringToMatch:find(aPatternCharacters[1])
			if matchIndex ~= nil then
				-- Distance of first match from start of a string
				score = score + bonusFirstMatch / matchIndex
				-- Number of matches in order
				-- Number of consecutive matches
				-- Distance between matches
				local matchIndices = {}
				table.insert(matchIndices, matchIndex)
				local consecutiveMatches = 0
				for i, char in ipairs(aPatternCharacters) do
					if i > 1 and matchIndices[i - 1] ~= nil then
						matchIndex = aStringToMatch:find(char, matchIndices[i - 1] + 1)
						if matchIndex ~= nil then
							table.insert(matchIndices, matchIndex)
							score = score + bonusMatch
							local distance = matchIndex - matchIndices[i - 1]
							if distance == 1 then
								consecutiveMatches = consecutiveMatches + 1
							else
								score = score + consecutiveMatches * bonusConsecutiveMatches
								consecutiveMatches = 0
							end
							score = score + bonusMatchDistance / distance
						else
							score = score + consecutiveMatches * bonusConsecutiveMatches
							score = score + penaltyNotMatch
							consecutiveMatches = 0
						end
					end
				end
				if consecutiveMatches > 0 then
					score = score + consecutiveMatches * bonusConsecutiveMatches
				end
				return true
			end
			return false
		end
		-- Matches in entire string
		if not match_string(patternCharacters, aString) then
			function slice(t, s, e)
				local r = {}
				for i = s or 1, e or #t do
					table.insert(r, t[i])
				end
				return r
			end
			local min = 1
			while not match_string(slice(patternCharacters, min), aString) and min < #patternCharacters do
				min = min + 1
			end
		end
		if #stringWords > 0 then
			-- Matches at beginning of words
			local j = 1
			for i, char in ipairs(patternCharacters) do
				if j <= #stringWords then
					if stringWords[j]:find(char) == 1 then
						score = score + bonusFirstWordMatch
						j = j + 1
					end
				end
			end
			-- Matches in words
			for i, word in ipairs(stringWords) do
				match_string(patternCharacters, word)
			end
		end
		if score < 0 then
			return 0
		end
		return score
	end

	function ClearFilter(atTable)
		if atTable == nil then
			return
		end
		local tResult = {}
		for i = 1, #atTable do
			if atTable[i][GAME_KEYS.HIDDEN] ~= true and atTable[i][GAME_KEYS.NOT_INSTALLED] ~= true  then
				table.insert(tResult, atTable[i])
			end
		end
		return tResult
	end

	function Sort()
		B_REVERSE_SORT = false
		SKIN:Bang('[!HideMeter "ToolbarButtonSortReverseIndicator"]')
		if T_FILTERED_GAMES ~= nil then
			if N_SORT_STATE == 1 then
				table.sort(T_FILTERED_GAMES, SortLastPlayed)
			elseif N_SORT_STATE == 2 then
				table.sort(T_FILTERED_GAMES, SortHoursPlayed)
			else
				table.sort(T_FILTERED_GAMES, SortAlphabetically)
			end
		end
		N_SCROLL_INDEX = 1
	end

	function SortAlphabetically(atFirst, atSecond)
		if atFirst[GAME_KEYS.NAME]:lower():gsub(':', ' ') < atSecond[GAME_KEYS.NAME]:lower():gsub(':', ' ') then
			return true
		else
			return false
		end
	end

	function SortLastPlayed(atFirst, atSecond)
		local nFirst = tonumber(atFirst[GAME_KEYS.LASTPLAYED])
		local nSecond = tonumber(atSecond[GAME_KEYS.LASTPLAYED])
		if nFirst > nSecond then
			return true
		elseif nFirst == nSecond then
			return SortAlphabetically(atFirst, atSecond)
		else
			return false
		end
	end

	function SortHoursPlayed(atFirst, atSecond)
		local nFirst = tonumber(atFirst[GAME_KEYS.HOURS_TOTAL])
		local nSecond = tonumber(atSecond[GAME_KEYS.HOURS_TOTAL])
		if nFirst > nSecond then
			return true
		elseif nFirst == nSecond then
			return SortAlphabetically(atFirst, atSecond)
		else
			return false
		end
	end

	function CycleSort()
		if N_SORT_STATE == nil then
			return
		end
		N_SORT_STATE = N_SORT_STATE + 1
		if N_SORT_STATE > 2 then
			N_SORT_STATE = 0
		end
		T_SETTINGS['sortstate'] = tostring(N_SORT_STATE)
		WriteSettings(T_SETTINGS)
		SKIN:Bang('[!SetOption "ToolbarButtonSort" "ImageName" "#@#Icons\\Sort' .. N_SORT_STATE .. '.png"][!UpdateMeterGroup Toolbar]')
		Sort()
		PopulateSlots()
	end

	function ReverseSort()
		B_REVERSE_SORT = not B_REVERSE_SORT
		if B_REVERSE_SORT == true then
			SKIN:Bang('[!ShowMeter "ToolbarButtonSortReverseIndicator"]')
		else
			SKIN:Bang('[!HideMeter "ToolbarButtonSortReverseIndicator"]')
		end
		local tReversedListOfGames = {}
		for i=1, #T_FILTERED_GAMES do
			table.insert(tReversedListOfGames, 1, T_FILTERED_GAMES[i])
		end
		T_FILTERED_GAMES = tReversedListOfGames
		PopulateSlots()
	end

	function PopulateSlots()
		if T_FILTERED_GAMES ~= nil then
			local nSlotCount = tonumber(T_SETTINGS[S_SETTING_SLOT_COUNT])
			local j = N_SCROLL_INDEX
			for i = 1, nSlotCount do -- Iterate through each slot.
				if j > 0 and j <= #T_FILTERED_GAMES then -- If the scroll index, 'j', is a valid index in the table 'T_FILTERED_GAMES'
					if BannerExists(T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH]) then
						SKIN:Bang('[!SetVariable SlotName' .. i .. ' ""][!SetVariable SlotImage' .. i .. ' "#@#Banners\\' .. T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH] .. '"]')
					else
						SKIN:Bang('[!SetVariable SlotName' .. i .. ' "' .. T_FILTERED_GAMES[j][GAME_KEYS.NAME] .. '"][!SetVariable SlotImage' .. i .. ' ""]')
					end
					if T_SETTINGS['slot_highlight'] then
						if N_LAUNCH_STATE == T_LAUNCH_STATES.LAUNCH then
							if T_SETTINGS['show_hours_played'] and T_FILTERED_GAMES[j][GAME_KEYS.HOURS_TOTAL] then
								local totalHoursPlayed = T_FILTERED_GAMES[j][GAME_KEYS.HOURS_TOTAL]
								local hoursPlayed = math.floor(totalHoursPlayed)
								local minutesPlayed = math.floor((totalHoursPlayed - hoursPlayed) * 60)
								if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Install via ' .. PLATFORM_DESCRIPTION[T_FILTERED_GAMES[j][GAME_KEYS.PLATFORM]+1] .. '#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
								elseif T_FILTERED_GAMES[j][GAME_KEYS.INVALID_PATH] == true then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Invalid path#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
								else
									if T_SETTINGS["show_platform"] then
										SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "' .. PLATFORM_DESCRIPTION[T_FILTERED_GAMES[j][GAME_KEYS.PLATFORM]+1] .. '#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
									else
										SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
									end								
								end
							else
								if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Install via ' .. PLATFORM_DESCRIPTION[T_FILTERED_GAMES[j][GAME_KEYS.PLATFORM]+1] .. '#CRLF##CRLF##CRLF##CRLF##CRLF#"]')
								elseif T_FILTERED_GAMES[j][GAME_KEYS.INVALID_PATH] == true then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Invalid path#CRLF##CRLF##CRLF##CRLF##CRLF#"]')
								else
									if T_SETTINGS["show_platform"] then
										SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "' .. PLATFORM_DESCRIPTION[T_FILTERED_GAMES[j][GAME_KEYS.PLATFORM]+1] .. '#CRLF##CRLF##CRLF##CRLF##CRLF#"]')
									else
										SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" ""]')
									end
								end
							end
							if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
								SKIN:Bang('[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightInstall.png"]')
							elseif T_FILTERED_GAMES[j][GAME_KEYS.ERROR] == true then
								SKIN:Bang('[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightError.png"]')
							else
								SKIN:Bang('[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightPlay.png"]')
							end
						elseif N_LAUNCH_STATE == T_LAUNCH_STATES.HIDE then
							SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Hide"][!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightHide.png"]')
						elseif N_LAUNCH_STATE == T_LAUNCH_STATES.UNHIDE then
							SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Unhide"][!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightUnhide.png"]')
						end
					end
				else -- Slot has no game to show.
					if T_SETTINGS['slot_highlight'] then
						SKIN:Bang('[!SetVariable SlotImage' .. i .. ' ""][!SetVariable SlotName' .. i .. ' ""][!SetVariable "SlotHighlightMessage' .. i .. '" ""]')
					else
						SKIN:Bang('[!SetVariable SlotImage' .. i .. ' ""][!SetVariable SlotName' .. i .. ' ""]')
					end
				end
				if T_SETTINGS['slot_highlight'] then
					SKIN:Bang('[!UpdateMeterGroup "SlotHighlight' .. i .. '"]')
				end
				j = j + 1
			end
		end
		SKIN:Bang('[!UpdateMeterGroup Slots][!Redraw]')
	end

	function Scroll(asDirection)
		local nSlotCount = tonumber(T_SETTINGS[S_SETTING_SLOT_COUNT])
		if #T_FILTERED_GAMES > nSlotCount then
			if tonumber(asDirection) >= 0 then
				if N_SCROLL_INDEX == 1 then
					return
				end
				N_SCROLL_INDEX = N_SCROLL_INDEX - N_SCROLL_STEP
				if N_SCROLL_INDEX < 1 then
					N_SCROLL_INDEX = 1
				end
			else
				local nUpperLimit = #T_FILTERED_GAMES + 1 - nSlotCount
				if N_SCROLL_INDEX == nUpperLimit then
					return
				end
				N_SCROLL_INDEX = N_SCROLL_INDEX + N_SCROLL_STEP
				if N_SCROLL_INDEX > nUpperLimit then
					N_SCROLL_INDEX = nUpperLimit
				end
			end
		end
	end

	function Launch(asIndex) -- asIndex is the index of the slot that was clicked
		if T_FILTERED_GAMES == nil then
			return
		end
		local nIndex = tonumber(asIndex) + N_SCROLL_INDEX - 1 -- nIndex is the index of the game in the T_FILTERED_GAMES table that is occupying the slot that was clicked
		local tGame = T_FILTERED_GAMES[nIndex]
		if tGame ~= nil then
			if N_LAUNCH_STATE == T_LAUNCH_STATES.LAUNCH then
				local sPath = tGame[GAME_KEYS.PATH]
				local tArguments = tGame[GAME_KEYS.ARGUMENTS]
				if sPath ~= nil then
					tGame[GAME_KEYS.LASTPLAYED] = os.time()
					bNotInstalled = tGame[GAME_KEYS.NOT_INSTALLED]
					if tGame[GAME_KEYS.HIDDEN] == true then
						tGame[GAME_KEYS.HIDDEN] = nil
						for i = 1, #T_HIDDEN_GAMES do -- Move game from T_HIDDEN_GAMES to T_ALL_GAMES
							if T_HIDDEN_GAMES[i] == tGame then
								table.insert(T_ALL_GAMES, table.remove(T_HIDDEN_GAMES, i))
								break
							end
						end
						if tGame[GAME_KEYS.NOT_INSTALLED] == true then
							tGame[GAME_KEYS.NOT_INSTALLED] = nil
						end
					elseif bNotInstalled == true then
						tGame[GAME_KEYS.NOT_INSTALLED] = nil
						for i = 1, #T_NOT_INSTALLED_GAMES do -- Move game from T_NOT_INSTALLED_GAMES to T_ALL_GAMES
							if T_NOT_INSTALLED_GAMES[i] == tGame then
								table.insert(T_ALL_GAMES, table.remove(T_NOT_INSTALLED_GAMES, i))
								break
							end
						end
					end
					WriteGames()
					FilterBy('')
					Sort()
					PopulateSlots()
					if tGame[GAME_KEYS.ERROR] == true then
						SKIN:Bang('[!Log "Error: There is something wrong with ' .. tGame[GAME_KEYS.NAME] .. '"]')
						return
					end
					if bNotInstalled ~= true then
						T_RECENTLY_LAUNCHED_GAME = tGame
						if tGame[GAME_KEYS.PLATFORM] == PLATFORM.STEAM then
							StartMonitoringProcess('GameOverlayUI.exe')
						elseif tGame[GAME_KEYS.PLATFORM] == PLATFORM.BATTLENET then
							StartMonitoringProcess(tGame[GAME_KEYS.PROCESS])
						elseif tGame[GAME_KEYS.PLATFORM] == PLATFORM.WINDOWS_URL_SHORTCUT then
							--
						else
							local processPath = string.gsub(string.gsub(sPath, "\\", "/"), "//", "/")
							local processName = processPath:reverse()
							processName = processName:match("(exe%p[^\\/:%*?<>|]+)/")
							if processName ~= nil then
								processName = processName:reverse()
								StartMonitoringProcess(processName)
							end
						end
						if T_SETTINGS['start_game_bang'] ~= nil and T_SETTINGS['start_game_bang'] ~= '' then
							SKIN:Bang((T_SETTINGS['start_game_bang']:gsub('`', '"')))
						end
					end
					if tArguments ~= nil then
						sArguments = table.concat(tArguments, '" "')
						SKIN:Bang('["' .. sPath .. '" "' .. sArguments .. '"]')
					else
						SKIN:Bang('["' .. sPath .. '"]')
					end
				end
			elseif N_LAUNCH_STATE == T_LAUNCH_STATES.HIDE then
				if tGame[GAME_KEYS.HIDDEN] ~= true then
					tGame[GAME_KEYS.HIDDEN] = true -- For (de)serializing purposes
					local bMoved = false
					for i = 1, #T_ALL_GAMES do -- Move game from T_ALL_GAMES to T_HIDDEN_GAMES
						if T_ALL_GAMES[i] == tGame then
							table.insert(T_HIDDEN_GAMES, table.remove(T_ALL_GAMES, i))
							bMoved = true
							break
						end
					end
					if not bMoved then
						for i = 1, #T_NOT_INSTALLED_GAMES do -- Move game from T_NOT_INSTALLED_GAMES to T_HIDDEN_GAMES
							if T_NOT_INSTALLED_GAMES[i] == tGame then
								table.insert(T_HIDDEN_GAMES, table.remove(T_NOT_INSTALLED_GAMES, i))
								break
							end
						end
					end
					WriteGames()
					for i = 1, #T_FILTERED_GAMES do -- Remove game from T_FILTERED_GAMES
						if T_FILTERED_GAMES[i] == tGame then
							table.remove(T_FILTERED_GAMES, i)
							break
						end
					end
					local scrollIndex = N_SCROLL_INDEX
					Sort()
					N_SCROLL_INDEX = scrollIndex
					PopulateSlots()
				end
			elseif N_LAUNCH_STATE == T_LAUNCH_STATES.UNHIDE then
				if tGame[GAME_KEYS.HIDDEN] == true then
					tGame[GAME_KEYS.HIDDEN] = nil -- For (de)serializing purposes
					if tGame[GAME_KEYS.NOT_INSTALLED] ~= true then
						for i = 1, #T_HIDDEN_GAMES do -- Move game from T_HIDDEN_GAMES to T_ALL_GAMES
							if T_HIDDEN_GAMES[i] == tGame then
								table.insert(T_ALL_GAMES, table.remove(T_HIDDEN_GAMES, i))
								break
							end
						end
					else
						for i = 1, #T_HIDDEN_GAMES do -- Move game from T_HIDDEN_GAMES to T_NOT_INSTALLED_GAMES
							if T_HIDDEN_GAMES[i] == tGame then
								table.insert(T_NOT_INSTALLED_GAMES, table.remove(T_HIDDEN_GAMES, i))
								break
							end
						end
					end
					WriteGames()
					for i = 1, #T_FILTERED_GAMES do -- Remove game from T_FILTERED_GAMES
						if T_FILTERED_GAMES[i] == tGame then
							table.remove(T_FILTERED_GAMES, i)
							break
						end
					end
					if #T_FILTERED_GAMES > 0 then
						local scrollIndex = N_SCROLL_INDEX
						Sort()
						N_SCROLL_INDEX = scrollIndex
						PopulateSlots()
					else
						UnhideGame()
						Sort()
						PopulateSlots()
					end
				end
			end
		end
	end

	function HideGame()
		if N_LAUNCH_STATE == T_LAUNCH_STATES.HIDE then
			N_LAUNCH_STATE = T_LAUNCH_STATES.LAUNCH
			PopulateSlots()
		else
			N_LAUNCH_STATE = T_LAUNCH_STATES.HIDE -- Set state where Launch function will instead set GAME_KEYS.HIDDEN to 'true'
			PopulateSlots()
		end
	end

	function UnhideGame()
		if N_LAUNCH_STATE == T_LAUNCH_STATES.UNHIDE then
			N_LAUNCH_STATE = T_LAUNCH_STATES.LAUNCH
			FilterBy('')
		else
			N_LAUNCH_STATE = T_LAUNCH_STATES.UNHIDE -- Set state where Launch function will instead set GAME_KEYS.HIDDEN to 'false'
			FilterBy('hidden:true') -- Adjust filtering to show games with GAME_KEYS.HIDDEN == 'true'.
		end
	end

	function StartMonitoringProcess(asString)
		SKIN:Bang('[!SetOption "ProcessMonitor" "UpdateDivider" "160"][!SetOption "ProcessMonitor" "ProcessName" "' .. asString .. '"][!UpdateMeasure "ProcessMonitor"]')
	end

	function UpdateTimePlayed()
		if T_RECENTLY_LAUNCHED_GAME ~= nil then
			local hoursPlayed = os.difftime(os.time(), T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.LASTPLAYED]) / 3600
			T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.HOURS_TOTAL] = hoursPlayed + T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.HOURS_TOTAL]
			WriteGames()
			PopulateSlots()
			ExecuteStoppingBang()
		end
		SKIN:Bang('[!SetOption "ProcessMonitor" "UpdateDivider" "-1"][!UpdateMeasure "ProcessMonitor"]')
	end

	function ExecuteStoppingBang()
		if T_SETTINGS['stop_game_bang'] ~= nil and T_SETTINGS['stop_game_bang'] ~= '' then
			SKIN:Bang((T_SETTINGS['stop_game_bang']:gsub('`', '"'))) -- The extra set of parentheses are used to just use the first return value of gsub
		end
	end

	function Unhighlight(asIndex)		
		if T_SETTINGS['slot_highlight'] then
			SKIN:Bang('[!HideMeterGroup "SlotHighlight' .. asIndex .. '"]')
		end
		if T_SETTINGS['hover_animation'] > 0 then
			if T_SETTINGS['orientation'] == 'vertical' then
				SKIN:Bang('[!SetVariable "SlotToAnimate" "' .. asIndex .. '"][!UpdateMeasure "HoverOffAnimation"][!CommandMeasure "HoverOffAnimation" "Execute 1"]')
			elseif T_SETTINGS['orientation'] == 'horizontal' then
				SKIN:Bang('[!SetVariable "SlotToAnimate" "' .. asIndex .. '"][!UpdateMeasure "HoverOffAnimation"][!CommandMeasure "HoverOffAnimation" "Execute 2"]')
			end
		else
			SKIN:Bang('[!Redraw]') --Optimization: This can be omitted if a slot is being animated
		end
	end

	function Highlight(asIndex)
		if T_FILTERED_GAMES == nil then
			return
		end
		local tGame = T_FILTERED_GAMES[tonumber(asIndex) + N_SCROLL_INDEX - 1]
		if tGame == nil then
			return
		end
		if T_SETTINGS['slot_highlight'] then
			SKIN:Bang('[!ShowMeterGroup "SlotHighlight' .. asIndex ..'"]')
		end
		if T_SETTINGS['hover_animation'] > 0 then
			if T_SETTINGS['hover_animation'] == 1 then
				if T_SETTINGS['orientation'] == 'vertical' then
					SKIN:Bang('[!SetVariable "SlotToAnimate" "' .. asIndex .. '"][!UpdateMeasure "HoverOnAnimation"][!CommandMeasure "HoverOnAnimation" "Execute 1"]')
				elseif T_SETTINGS['orientation'] == 'horizontal' then
					SKIN:Bang('[!SetVariable "SlotToAnimate" "' .. asIndex .. '"][!UpdateMeasure "HoverOnAnimation"][!CommandMeasure "HoverOnAnimation" "Execute 2"]')
				end
			elseif T_SETTINGS['hover_animation'] == 2 then
				SKIN:Bang('[!SetVariable "SlotToAnimate" "' .. asIndex .. '"][!UpdateMeasure "HoverOnAnimation"][!CommandMeasure "HoverOnAnimation" "Execute 3"]')
			elseif T_SETTINGS['hover_animation'] == 3 then
				SKIN:Bang('[!SetVariable "SlotToAnimate" "' .. asIndex .. '"][!UpdateMeasure "HoverOnAnimation"][!CommandMeasure "HoverOnAnimation" "Execute 4"]')
			end
		else
			SKIN:Bang('[!Redraw]') --Optimization: This can be omitted if a slot is being animated
		end
	end

-- Error messages
	function ShowMessage(asMessage)
		SKIN:Bang('[!SetVariable Message ' .. asMessage .. '][!ShowMeterGroup Message][!Redraw]')
	end

	function HideMessage()
		SKIN:Bang('[!HideMeterGroup Message][!Redraw]')
	end

-- Toolbar
	function ShowToolbar()
		if B_REVERSE_SORT then
			SKIN:Bang('[!ShowMeter "ToolbarButtonSortReverseIndicator"]')
		end
		SKIN:Bang('[!ShowMeterGroup Toolbar][!Redraw]')
	end

	function HideToolbar()
		if B_FORCE_TOOLBAR == false then
			if B_REVERSE_SORT then
				SKIN:Bang('[!HideMeter "ToolbarButtonSortReverseIndicator"]')
			end
			SKIN:Bang('[!HideMeterGroup Toolbar][!Redraw]')
		end
	end

	function ForceShowToolbar()
		B_FORCE_TOOLBAR = true
		ShowToolbar()
	end

	function ForceHideToolbar()
		B_FORCE_TOOLBAR = false
		HideToolbar()
	end
