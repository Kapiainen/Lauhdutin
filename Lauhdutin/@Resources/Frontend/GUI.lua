function Initialize()
	json = dofile(SKIN:GetVariable('@') .. 'Dependencies\\json4lua\\json.lua')
	S_PATH_RESOURCES = SKIN:GetVariable('@')
	S_VDF_SERIALIZING_INDENTATION = ''
	T_SETTINGS = ReadSettings()
	if T_SETTINGS == nil then
		SKIN:Bang('[!SetOption StatusMessage Text "Load Settings.ini and save settings."][!ShowMeterGroup Status #CURRENTCONFIG#][!Redraw]')
		return
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
		BANNER_ERROR = "bannererror",
		BANNER_PATH = "banner",
		BANNER_URL = "bannerurl",
		HIDDEN = "hidden",
		HOURS_LAST_TWO_WEEKS = "hourslast2weeks",
		HOURS_TOTAL = "hourstotal",
		LASTPLAYED = "lastplayed",
		NAME = "title",
		NOT_INSTALLED = "notinstalled",
		PATH = "path",
		PLATFORM = "platform",
		TAGS = "tags"
	}
	-- If PLATFORM values are changed, then they have to be copied to the Platform class in Enums.py.
	PLATFORM = {
		STEAM = 0,
		STEAM_SHORTCUT = 1,
		GOG_GALAXY = 2,
		WINDOWS_SHORTCUT = 3
	}
	PLATFORM_DESCRIPTION = {
		"Steam",
		"Steam",
		"GOG Galaxy",
		""
	}
	B_FORCE_TOOLBAR = false
	HideToolbar()
end

-- Called once after Initialize() has been called. Runs Backend\GetGames.py.
function Update()
	if T_SETTINGS ~= nil then
		SKIN:Bang('[!SetOption StatusMessage Text "Initializing backend..."][!ShowMeterGroup Status #CURRENTCONFIG#][!Redraw]')
		SKIN:Bang('"#Python#" "#@#Backend\\GetGames.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"')
	end
end

-- Called by Backend\GetGames.py when it has successfully completed its task.
function Init()
	SKIN:Bang('[!HideMeterGroup Status #CURRENTCONFIG#][!Redraw]')
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
		SKIN:Bang('[!SetOption StatusMessage Text "No games to display"][!ShowMeterGroup Status #CURRENTCONFIG#][!Redraw]')
	end
	for i=1, tonumber(T_SETTINGS['slot_count']) do
		SKIN:Bang('[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightPlay.png"]')
	end
	for i=1, tonumber(T_SETTINGS['slot_count']) do
		SKIN:Bang('[!HideMeterGroup "SlotHighlight' .. i .. '"]')
	end
	PopulateSlots()
	SKIN:Bang('[!Redraw]')
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
		asPattern = asPattern:lower()
		if StartsWith(asPattern, '+') then
			T_FILTERED_GAMES = Filter(T_FILTERED_GAMES, asPattern:sub(2))
		else
			T_FILTERED_GAMES = Filter(T_ALL_GAMES, asPattern)
		end
		Sort()
		PopulateSlots()
	end

	function Filter(atTable, asPattern)
		if atTable == nil then
			return
		end
		tResult = {}
		if StartsWith(asPattern, 'steam:') then
			asPattern = asPattern:sub(7)
			if StartsWith(asPattern, 't') then
				for i = 1, #atTable do
					if atTable[i][GAME_KEYS.PLATFORM] == PLATFORM.STEAM then
						table.insert(tResult, atTable[i])
					end
				end
			elseif StartsWith(asPattern, 'f') then
				for i = 1, #atTable do
					if atTable[i][GAME_KEYS.PLATFORM] ~= PLATFORM.STEAM then
						table.insert(tResult, atTable[i])
					end
				end
			else
				return tResult
			end
		elseif StartsWith(asPattern, 'galaxy:') then
			asPattern = asPattern:sub(8)
			if StartsWith(asPattern, 't') then
				for i = 1, #atTable do
					if atTable[i][GAME_KEYS.PLATFORM] == PLATFORM.GOG_GALAXY then
						table.insert(tResult, atTable[i])
					end
				end
			elseif StartsWith(asPattern, 'f') then
				for i = 1, #atTable do
					if atTable[i][GAME_KEYS.PLATFORM] ~= PLATFORM.GOG_GALAXY then
						table.insert(tResult, atTable[i])
					end
				end
			else
				return tResult
			end
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
				return tResult
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
				return tResult
			end
		else
			for i = 1, #atTable do
				if atTable[i][GAME_KEYS.NAME]:lower():find(asPattern) then
					table.insert(tResult, atTable[i])
				end
			end
		end
		return tResult
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
		if T_FILTERED_GAMES ~= nil then
			if N_SORT_STATE == 1 then
				table.sort(T_FILTERED_GAMES, SortLastPlayed)
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
		if tonumber(atFirst[GAME_KEYS.LASTPLAYED]) > tonumber(atSecond[GAME_KEYS.LASTPLAYED]) then
			return true
		else
			return false
		end
	end

	function CycleSort()
		if N_SORT_STATE == nil then
			return
		end
		N_SORT_STATE = N_SORT_STATE + 1
		if N_SORT_STATE > 1 then
			N_SORT_STATE = 0
		end
		T_SETTINGS['sortstate'] = tostring(N_SORT_STATE)
		WriteSettings(T_SETTINGS)
		SKIN:Bang('[!SetOption "ToolbarButtonSort" "ImageName" "#@#Icons\\Sort' .. N_SORT_STATE .. '.png"][!UpdateMeterGroup Toolbar][!Redraw]')
		Sort()
		PopulateSlots()
	end

	function PopulateSlots()
		if T_FILTERED_GAMES ~= nil then
			local nSlotCount = tonumber(T_SETTINGS[S_SETTING_SLOT_COUNT])
			local j = N_SCROLL_INDEX
			for i = 1, nSlotCount do
				if j > 0 and j <= #T_FILTERED_GAMES then
					SKIN:Bang('[!SetVariable SlotPath' .. i .. ' "' .. tostring(j) .. '"][!SetVariable SlotName' .. i .. ' "' .. T_FILTERED_GAMES[j][GAME_KEYS.NAME] .. '"]')
					if BannerExists(T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH]) then
						SKIN:Bang('!SetVariable SlotImage' .. i .. ' "#@#Banners\\' .. T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH] .. '"')
					else
						SKIN:Bang('!SetVariable SlotImage' .. i .. ' ""')
					end
					if N_LAUNCH_STATE == T_LAUNCH_STATES.LAUNCH then
						if T_SETTINGS['show_hours_played'] and T_FILTERED_GAMES[j][GAME_KEYS.HOURS_TOTAL] then
							local totalHoursPlayed = T_FILTERED_GAMES[j][GAME_KEYS.HOURS_TOTAL]
							local hoursPlayed = math.floor(totalHoursPlayed)
							local minutesPlayed = math.floor((totalHoursPlayed - hoursPlayed) * 60)
							if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
								SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Install via ' .. PLATFORM_DESCRIPTION[T_FILTERED_GAMES[j][GAME_KEYS.PLATFORM]+1] .. '#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')--[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightInstall.png"]')
							else
								SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "' .. PLATFORM_DESCRIPTION[T_FILTERED_GAMES[j][GAME_KEYS.PLATFORM]+1] .. '#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')--[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightPlay.png"]')
							end
						else
							if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
								SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Install via ' .. PLATFORM_DESCRIPTION[T_FILTERED_GAMES[j][GAME_KEYS.PLATFORM]+1] .. '#CRLF##CRLF##CRLF##CRLF##CRLF#"]')--[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightInstall.png"]')
							else
								SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "' .. PLATFORM_DESCRIPTION[T_FILTERED_GAMES[j][GAME_KEYS.PLATFORM]+1] .. '#CRLF##CRLF##CRLF##CRLF##CRLF#"]')--[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightPlay.png"]')
							end
						end
						if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
							SKIN:Bang('[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightInstall.png"]')
						else
							SKIN:Bang('[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightPlay.png"]')
						end
					elseif N_LAUNCH_STATE == T_LAUNCH_STATES.HIDE then
						SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Hide"][!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightHide.png"]')
					elseif N_LAUNCH_STATE == T_LAUNCH_STATES.UNHIDE then
						SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Unhide"][!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightUnhide.png"]')
					end
				else
					SKIN:Bang('[!SetVariable SlotPath' .. i .. ' ""][!SetVariable SlotImage' .. i .. ' ""][!SetVariable SlotName' .. i .. ' ""][!SetVariable "SlotHighlightMessage' .. i .. '" ""]')
				end
				SKIN:Bang('[!UpdateMeterGroup "SlotHighlight' .. i .. '"]')
				j = j + 1
			end
		end
		SKIN:Bang('[!UpdateMeterGroup Slots][!Redraw]')
	end

	function Scroll(asDirection)
		if #T_FILTERED_GAMES > tonumber(T_SETTINGS[S_SETTING_SLOT_COUNT]) then
			local abUpwards = true
			if tonumber(asDirection) < 0 then
				abUpwards = false
			end
			if abUpwards then
				N_SCROLL_INDEX = N_SCROLL_INDEX - N_SCROLL_STEP
				if N_SCROLL_INDEX < 1 then
					N_SCROLL_INDEX = 1
				end
			else
				N_SCROLL_INDEX = N_SCROLL_INDEX + N_SCROLL_STEP
				if N_SCROLL_INDEX + tonumber(T_SETTINGS[S_SETTING_SLOT_COUNT]) > #T_FILTERED_GAMES + 1 then
					N_SCROLL_INDEX = #T_FILTERED_GAMES + 1 - tonumber(T_SETTINGS[S_SETTING_SLOT_COUNT])
				end
			end
			PopulateSlots()
		end
	end

	function Launch(asIndex)
		if T_FILTERED_GAMES == nil then
			return
		end
		local nIndex = tonumber(asIndex)
		local tGame = T_FILTERED_GAMES[nIndex]
		if tGame ~= nil then
			if N_LAUNCH_STATE == T_LAUNCH_STATES.LAUNCH then
				local sPath = tGame[GAME_KEYS.PATH]
				if sPath ~= nil then
					tGame[GAME_KEYS.LASTPLAYED] = os.time()
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
					elseif tGame[GAME_KEYS.NOT_INSTALLED] == true then
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
					T_RECENTLY_LAUNCHED_GAME = tGame
					if StartsWith(sPath, 'steam://') then
						SKIN:Bang('[!SetOption "ProcessMonitor" "ProcessName" "GameOverlayUI.exe"]')
					else
						local processPath = string.gsub(string.gsub(sPath, "\\", "/"), "//", "/")
						local processName = processPath:reverse():match("(exe%p[^\\/:%*?<>|]+)/"):reverse()
						SKIN:Bang('[!SetOption "ProcessMonitor" "ProcessName" "' .. processName .. '"]')
					end
					SKIN:Bang('[!UpdateMeasure "ProcessMonitor"]')
					SKIN:Bang('["' .. sPath .. '"]')
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
					local scrollIndex = N_SCROLL_INDEX
					Sort()
					N_SCROLL_INDEX = scrollIndex
					PopulateSlots()
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

	function UpdateTimePlayed()
		if T_RECENTLY_LAUNCHED_GAME ~= nil then
			local hoursPlayed = os.difftime(os.time(), T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.LASTPLAYED]) / 3600
			T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.HOURS_TOTAL] = hoursPlayed + T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.HOURS_TOTAL]
			WriteGames()
			PopulateSlots()
		end
	end

	function Highlight(asIndex)
		if T_FILTERED_GAMES == nil then
			return
		end
		if not T_SETTINGS['slot_highlight'] then
			return
		end
		local nIndex = tonumber(asIndex)
		if asIndex == '-1' then
			for i=1, tonumber(T_SETTINGS['slot_count']) do
				SKIN:Bang('[!HideMeterGroup "SlotHighlight' .. i .. '"]')
			end
			SKIN:Bang('[!Redraw]')
		else
			local tGame = T_FILTERED_GAMES[nIndex]
			if tGame ~= nil then
				for i=1, tonumber(T_SETTINGS['slot_count']) do
					if i ~= nIndex then
						SKIN:Bang('[!HideMeterGroup "SlotHighlight' .. i .. '"]')
					end
				end
				SKIN:Bang('[!ShowMeterGroup "SlotHighlight' .. asIndex ..'"][!UpdateMeterGroup "SlotHighlight' .. asIndex ..'"][!Redraw]')
			end
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
		SKIN:Bang('[!ShowMeterGroup Toolbar][!Redraw]')
	end

	function HideToolbar()
		if B_FORCE_TOOLBAR == false then
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
