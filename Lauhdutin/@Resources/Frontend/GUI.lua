function Initialize()
	json = dofile(SKIN:GetVariable('@') .. 'Dependencies\\json4lua\\json.lua')
	S_PATH_RESOURCES = SKIN:GetVariable('@')
	S_VDF_SERIALIZING_INDENTATION = ''
	T_SETTINGS = ReadSettings()
	if T_SETTINGS == nil then
		SKIN:Bang('[!SetOption StatusMessage Text "Load Settings.ini and save settings."][!ShowMeterGroup Status #CURRENTCONFIG#][!Redraw]')
		return
	end
	N_SORT_STATE = 0 --0 = alphabetically, 1 = most recently played
	if T_SETTINGS['sortstate'] then
		N_SORT_STATE = tonumber(T_SETTINGS['sortstate']) - 1
		CycleSort()
	end
	S_SETTING_SLOT_COUNT = 'slot_count'
	T_ALL_GAMES = {} -- all games found in 'games.json'
	T_FILTERED_GAMES = {} -- subset of T_ALL_GAMES
	N_SCROLL_INDEX = 1
	N_SCROLL_STEP = 1
	-- If GAME_KEYS values are changed, then they have to be copied to the GameKeys class in Enums.py.
	GAME_KEYS = {
		BANNER_ERROR = "bannererror",
		BANNER_PATH = "banner",
		BANNER_URL = "bannerurl",
		HIDDEN = "hidden",
		LASTPLAYED = "lastplayed",
		NAME = "title",
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
	T_ALL_GAMES = {}
	for sKey, tTable in pairs(tGames) do
		if tTable[GAME_KEYS.HIDDEN] ~= '1' then
			table.insert(T_ALL_GAMES, tTable)
		end
	end
	T_FILTERED_GAMES = T_ALL_GAMES
	Sort()
	PopulateSlots()
	if T_ALL_GAMES == nil or #T_ALL_GAMES == 0 then
		SKIN:Bang('[!SetOption StatusMessage Text "No games to display"][!ShowMeterGroup Status #CURRENTCONFIG#][!Redraw]')
	end
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

	function WriteGames(atTable)
		return WriteJSON(S_PATH_RESOURCES .. 'games.json', atTable)
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
			ClearFilter()
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
		else
			for i = 1, #atTable do
				if atTable[i][GAME_KEYS.NAME]:lower():find(asPattern) then
					table.insert(tResult, atTable[i])
				end
			end
		end
		return tResult
	end

	function ClearFilter()
		T_FILTERED_GAMES = T_ALL_GAMES
		Sort()
		PopulateSlots()
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
					SKIN:Bang('!SetVariable SlotPath' .. i .. ' "' .. tostring(j) .. '"')
					SKIN:Bang('!SetVariable SlotName' .. i .. ' "' .. T_FILTERED_GAMES[j][GAME_KEYS.NAME] .. '"')
					if BannerExists(T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH]) then
						SKIN:Bang('!SetVariable SlotImage' .. i .. ' "#@#Banners\\' .. T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH] .. '"')
					else
						SKIN:Bang('!SetVariable SlotImage' .. i .. ' ""')
					end
				else
					SKIN:Bang('!SetVariable SlotPath' .. i .. ' ""')
					SKIN:Bang('!SetVariable SlotImage' .. i .. ' ""')
					SKIN:Bang('!SetVariable SlotName' .. i .. ' ""')
				end
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
			local sTitle = tGame[GAME_KEYS.NAME]
			local sPath = tGame[GAME_KEYS.PATH]
			if sTitle ~= nil and sPath ~= nil then
				for i = 1, #T_ALL_GAMES do
					if T_ALL_GAMES[i][GAME_KEYS.NAME] == sTitle then
						T_ALL_GAMES[i][GAME_KEYS.LASTPLAYED] = os.time()
						WriteGames(T_ALL_GAMES)
						if N_SORT_STATE == 1 then
							Sort(T_FILTERED_GAMES)
							PopulateSlots()
						end
						SKIN:Bang('["' .. sPath .. '"]')
						break
					end
				end
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
