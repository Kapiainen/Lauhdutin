function Initialize()
	JSON = dofile(SKIN:GetVariable('@') .. 'Dependencies\\json4lua\\json.lua')
	RESOURCES_PATH = SKIN:GetVariable('@')
	REBUILD_SWITCH = false
	SAVING_SETTINGS = false
	SETTINGS = ReadSettings()
	OLD_SETTINGS = ReadSettings()
	if SETTINGS == nil then
		SETTINGS = {}
	end
	if SETTINGS['slot_count'] == nil then
		SETTINGS['slot_count'] = 8
	end
	if SETTINGS['slot_width'] == nil then
		SETTINGS['slot_width'] = 310
	end
	if SETTINGS['slot_height'] == nil then
		SETTINGS['slot_height'] = 145
	end
	if SETTINGS['slot_background_color'] == nil then
		SETTINGS['slot_background_color'] = "0,0,0,196"
	end
	if SETTINGS['slot_text_color'] == nil then
		SETTINGS['slot_text_color'] = "255,255,255,255"
	end
	if SETTINGS['slot_highlight'] == nil then
		SETTINGS['slot_highlight'] = true
	end
	if SETTINGS['show_hours_played'] == nil then
		SETTINGS['show_hours_played'] = true
	end
	if SETTINGS['show_platform'] == nil then
		SETTINGS['show_platform'] = true
	end
	if SETTINGS['steam_path'] == nil then
		SETTINGS['steam_path'] = ""
	end
	if SETTINGS['steam_userdataid'] == nil then
		SETTINGS['steam_userdataid'] = ""
	end
	if SETTINGS['steam_personaname'] == nil then
		SETTINGS['steam_personaname'] = "" -- Just used for visuals in the Settings menu
	end
	if SETTINGS['steam_id64'] == nil then
		SETTINGS['steam_id64'] = ""
	end
	if SETTINGS['parse_steam_community_profile'] == nil then
		SETTINGS['parse_steam_community_profile'] = true
	end
	if SETTINGS['start_game_bang'] == nil then
		SETTINGS['start_game_bang'] = ""
	end
	if SETTINGS['stop_game_bang'] == nil then
		SETTINGS['stop_game_bang'] = ""
	end
	if SETTINGS['sortstate'] == nil then
		SETTINGS['sortstate'] = "0"
	end
	if SETTINGS['galaxy_path'] == nil then
		SETTINGS['galaxy_path'] = "C:\/ProgramData\/GOG.com\/Galaxy"
	end
	if SETTINGS['battlenet_path'] == nil then
		SETTINGS['battlenet_path'] = ""
	end
	if SETTINGS['python_path'] == nil then
		SETTINGS['python_path'] = "pythonw"
	end
	if SETTINGS['orientation'] == nil then
		SETTINGS['orientation'] = "vertical"
	end
	if SETTINGS['click_animation'] == nil then
		SETTINGS['click_animation'] = 0
	end
	CLICK_ANIMATION_DESCRIPTIONS = {
		"Shrink",
		"Shift left",
		"Shift right",
		"Shrink",
		"Shift up",
		"Shift down"
	}
	if SETTINGS['hover_animation'] == nil then
		SETTINGS['hover_animation'] = 0
	end
	HOVER_ANIMATION_DESCRIPTIONS = {
		"Zoom in",
		"Jiggle",
		"Shake"
	}
	if SETTINGS['fuzzy_search'] == nil then
		SETTINGS['fuzzy_search'] = true
	end
	SKIN:Bang('[!HideMeterGroup "Paths"]')
	UpdateSettings()
end

function Update()

end

function WritePythonPath()
	local f = io.open(RESOURCES_PATH .. 'PythonPath.inc', 'w')
	if f ~= nil then
		f:write('[Variables]\nPython="' .. SETTINGS['python_path'] .. '"')
		f:close()
	end
end

function Save()
	SAVING_SETTINGS = true
	if OLD_SETTINGS then
		if OLD_SETTINGS['python_path'] ~= SETTINGS['python_path'] and SETTINGS['python_path'] ~= '' then
			WritePythonPath()
		end
	else
		WritePythonPath()
		REBUILD_SWITCH = true
	end
	WriteSettings(SETTINGS)
	SAVING_SETTINGS = false
end

function Exit()
	if SAVING_SETTINGS then
		return
	end
	if OLD_SETTINGS then
		local layout_settings = {'slot_count', 'slot_width', 'slot_height', 'slot_background_color', 'slot_text_color', 'orientation', 'click_animation', 'hover_animation'}
		for i=1, #layout_settings do
			if OLD_SETTINGS[layout_settings[i]] ~= SETTINGS[layout_settings[i]] then
				REBUILD_SWITCH = true
				break
			end
		end
	end
	if REBUILD_SWITCH then
		SKIN:Bang('["#Python#" "#@#Frontend\\BuildSkin.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;" "#CURRENTFILE#;"]')
	else
		SKIN:Bang('[!ActivateConfig "#CURRENTCONFIG#" "Main.ini"]')
	end	
end

function SelectTab(aNewTab, aOldTab)
	if aNewTab ~= aOldTab then
		SKIN:Bang('[!HideMeterGroup "' .. aOldTab .. '"]')
		SKIN:Bang('[!ShowMeterGroup "' .. aNewTab .. '"]')
		SKIN:Bang('[!SetVariable CurrentTab "' .. aNewTab .. '"]')
		SKIN:Bang('[!SetOption "' .. aNewTab .. 'Tab" "SolidColor" "#SelectedButtonColor#"]')
		SKIN:Bang('[!SetOption "' .. aOldTab .. 'Tab" "SolidColor" "#UnselectedButtonColor#"]')
		SKIN:Bang('[!Update]')
		SKIN:Bang('[!Redraw]')
	end
end

function UpdateSettings()
	if SETTINGS then
		SKIN:Bang('[!SetOption "SlotCountStatus" "Text" "' .. tostring(SETTINGS['slot_count']) .. '"]')
		SKIN:Bang('[!SetOption "SlotCountInput" "DefaultValue" "' .. SETTINGS['slot_count'] ..'"]')
		SKIN:Bang('[!SetOption "SlotWidthStatus" "Text" "' .. tostring(SETTINGS['slot_width']) .. '"]')
		SKIN:Bang('[!SetOption "SlotWidthInput" "DefaultValue" "' .. SETTINGS['slot_width'] ..'"]')
		SKIN:Bang('[!SetOption "SlotHeightStatus" "Text" "' .. tostring(SETTINGS['slot_height']) .. '"]')
		SKIN:Bang('[!SetOption "SlotHeightInput" "DefaultValue" "' .. SETTINGS['slot_height'] ..'"]')
		SKIN:Bang('[!SetOption "SteamPathStatus" "Text" "' .. tostring(SETTINGS['steam_path']) .. '"]')
		SKIN:Bang('[!SetOption "SteamPathInput" "DefaultValue" "' .. SETTINGS['steam_path'] ..'"]')
		SKIN:Bang('[!SetOption "SteamUserdataidStatus" "Text" "' .. tostring(SETTINGS['steam_personaname']) .. '"]')
		SKIN:Bang('[!SetOption "SteamUserdataidInput" "DefaultValue" "' .. SETTINGS['steam_userdataid'] ..'"]')
		SKIN:Bang('[!SetOption "GalaxyPathStatus" "Text" "' .. tostring(SETTINGS['galaxy_path']) .. '"]')
		SKIN:Bang('[!SetOption "GalaxyPathInput" "DefaultValue" "' .. SETTINGS['galaxy_path'] ..'"]')
		SKIN:Bang('[!SetOption "BattlenetPathStatus" "Text" "' .. tostring(SETTINGS['battlenet_path']) .. '"]')
		SKIN:Bang('[!SetOption "BattlenetPathInput" "DefaultValue" "' .. SETTINGS['battlenet_path'] ..'"]')
		SKIN:Bang('[!SetOption "PythonPathStatus" "Text" "' .. tostring(SETTINGS['python_path']) .. '"]')
		SKIN:Bang('[!SetOption "PythonPathInput" "DefaultValue" "' .. SETTINGS['python_path'] ..'"]')
		SKIN:Bang('[!SetOption "StartGameBangStatus" "Text" "' .. tostring(SETTINGS['start_game_bang']) .. '"]')
		SKIN:Bang('[!SetOption "StartGameBangInput" "DefaultValue" "' .. SETTINGS['start_game_bang'] ..'"]')
		SKIN:Bang('[!SetOption "StopGameBangStatus" "Text" "' .. tostring(SETTINGS['stop_game_bang']) .. '"]')
		SKIN:Bang('[!SetOption "StopGameBangInput" "DefaultValue" "' .. SETTINGS['stop_game_bang'] ..'"]')
		if SETTINGS['orientation'] == 'vertical' then
			SKIN:Bang('[!SetOption "SkinOrientationStatus" "Text" "Vertical"]')
			if SETTINGS['click_animation'] > #CLICK_ANIMATION_DESCRIPTIONS / 2 then
				SETTINGS['click_animation'] = 0
			end
		else
			SKIN:Bang('[!SetOption "SkinOrientationStatus" "Text" "Horizontal"]')
			if SETTINGS['click_animation'] <= #CLICK_ANIMATION_DESCRIPTIONS / 2 then
				SETTINGS['click_animation'] = 0
			end
		end
		if SETTINGS['slot_highlight'] == true then
			SKIN:Bang('[!SetOption "SlotHighlightingStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "SlotHighlightingStatus" "Text" "Disabled"]')
		end
		if SETTINGS['show_hours_played'] == true then
			SKIN:Bang('[!SetOption "ShowHoursPlayedStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "ShowHoursPlayedStatus" "Text" "Disabled"]')
		end
		if SETTINGS['show_platform'] == true then
			SKIN:Bang('[!SetOption "ShowPlatformStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "ShowPlatformStatus" "Text" "Disabled"]')
		end
		if SETTINGS['click_animation'] == 0 then
			SKIN:Bang('[!SetOption "ClickAnimationStatus" "Text" "Disabled"]')
		else
			SKIN:Bang('[!SetOption "ClickAnimationStatus" "Text" "' .. CLICK_ANIMATION_DESCRIPTIONS[SETTINGS['click_animation']] .. '"]')
		end
		if SETTINGS['hover_animation'] == 0 then
			SKIN:Bang('[!SetOption "HoverAnimationStatus" "Text" "Disabled"]')
		else
			SKIN:Bang('[!SetOption "HoverAnimationStatus" "Text" "' .. HOVER_ANIMATION_DESCRIPTIONS[SETTINGS['hover_animation']] .. '"]')
		end
		if SETTINGS['fuzzy_search'] == true then
			SKIN:Bang('[!SetOption "FuzzySearchStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "FuzzySearchStatus" "Text" "Disabled"]')
		end
		if SETTINGS['parse_steam_community_profile'] == true then
			SKIN:Bang('[!SetOption "SteamProfileStatus" "Text" "Parse"]')
		else
			SKIN:Bang('[!SetOption "SteamProfileStatus" "Text" "Ignore"]')
		end
		SKIN:Bang('[!Update]')
		SKIN:Bang('[!Redraw]')
	end
end

function IncrementSlotCount()
	SETTINGS['slot_count'] = SETTINGS['slot_count'] + 1
	UpdateSettings()
end

function DecrementSlotCount()
	if SETTINGS['slot_count'] > 1 then
		SETTINGS['slot_count'] = SETTINGS['slot_count'] - 1
		UpdateSettings()
	end
end

function SetSlotCount(aValue)
	local numVal = tonumber(aValue)
	if numVal and numVal > 0 then
		SETTINGS['slot_count'] = numVal
		UpdateSettings()
	end
end


function IncrementSlotWidth()
	SETTINGS['slot_width'] = SETTINGS['slot_width'] + 1
	UpdateSettings()
end

function DecrementSlotWidth()
	if SETTINGS['slot_width'] > 1 then
		SETTINGS['slot_width'] = SETTINGS['slot_width'] - 1
		UpdateSettings()
	end
end

function SetSlotWidth(aValue)
	local numVal = tonumber(aValue)
	if numVal and numVal > 0 then
		SETTINGS['slot_width'] = numVal
		UpdateSettings()
	end
end


function IncrementSlotHeight()
	SETTINGS['slot_height'] = SETTINGS['slot_height'] + 1
	UpdateSettings()
end

function DecrementSlotHeight()
	if SETTINGS['slot_height'] > 1 then
		SETTINGS['slot_height'] = SETTINGS['slot_height'] - 1
		UpdateSettings()
	end
end

function SetSlotHeight(aValue)
	local numVal = tonumber(aValue)
	if numVal and numVal > 0 then
		SETTINGS['slot_height'] = numVal
		UpdateSettings()
	end
end


function RequestSteamPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFolderPathDialog.py" "#PROGRAMPATH#;" "AcceptSteamPath;" "' .. SETTINGS['steam_path'] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptSteamPath(aPath)
	SETTINGS['steam_path'] = aPath
	UpdateSettings()
end

function RequestSteamUserdataid()
	local initialDir = ''
	if SETTINGS['steam_path'] ~= '' then
		initialDir = SETTINGS['steam_path'] .. '\\userdata'
	end
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFolderPathDialog.py" "#PROGRAMPATH#;" "AcceptSteamUserdataid;" "' .. initialDir .. '"; "#CURRENTCONFIG#;"')
end

function AcceptSteamUserdataid(aPath)
	if aPath ~= nil and aPath ~= '' then
		local udid = ''
		for element in string.gmatch(aPath, '%d+') do
			udid = element
		end
		if udid ~= '' then
			SETTINGS['steam_userdataid'] = udid
			local personaName = ''
			local configPath = aPath .. '/config/localconfig.vdf'
			local f = io.open(configPath, 'r')
			if f ~= nil then -- Browsed to UserDataID folder
				local contents = f:read('*a')
				for match in string.gmatch(contents, '"PersonaName"%s+"([^"]+)"') do
					personaName = match
					break
				end
				f:close()
			else -- User inputs UserDataID manually in skin
				configPath = SETTINGS['steam_path'] .. '/userdata/' .. udid .. '/config/localconfig.vdf'
				local f = io.open(configPath, 'r')
				if f ~= nil then
					local contents = f:read('*a')
					for match in string.gmatch(contents, '"PersonaName"%s+"([^"]+)"') do
						personaName = match
						break
					end
					f:close()
				end
			end
			SETTINGS['steam_personaname'] = personaName
			SETTINGS['steam_id64'] = ''
			if personaName ~= '' and SETTINGS['steam_path'] ~= nil then
				local loginusers = ParseVDFFile(SETTINGS['steam_path'] .. '/config/loginusers.vdf')
				if loginusers ~= nil then
					local users = loginusers['users']
					if users ~= nil then
						for steamID64, accountTable in pairs(users) do
							if accountTable['personaname'] == personaName then
								SETTINGS['steam_id64'] = steamID64
								break
							end
						end
					end
				end
			end
			if SETTINGS['steam_id64'] == '' then
				print('Lauhdutin: Failed to figure out SteamID64 for ' .. personaName)
			end
			UpdateSettings()
		end
	else
		SETTINGS['steam_userdataid'] = ''
		SETTINGS['steam_personaname'] = ''
		UpdateSettings()
	end
end

function ToggleSteamProfile()
	SETTINGS['parse_steam_community_profile'] = not SETTINGS['parse_steam_community_profile']
	UpdateSettings()
end

function RequestGalaxyPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFolderPathDialog.py" "#PROGRAMPATH#;" "AcceptGalaxyPath;" "' .. SETTINGS['galaxy_path'] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptGalaxyPath(aPath)
	SETTINGS['galaxy_path'] = aPath
	UpdateSettings()
end

function RequestBattlenetPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFolderPathDialog.py" "#PROGRAMPATH#;" "AcceptBattlenetPath;" "' .. SETTINGS['battlenet_path'] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptBattlenetPath(aPath)
	SETTINGS['battlenet_path'] = aPath
	UpdateSettings()
end

function RequestPythonPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFilePathDialog.py" "#PROGRAMPATH#;" "AcceptPythonPath;" "' .. SETTINGS['python_path'] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptPythonPath(aPath)
	SETTINGS['python_path'] = aPath
	UpdateSettings()
end

function AcceptStartGameBang(aPath)
	SETTINGS['start_game_bang'] = aPath
	UpdateSettings()
end

function AcceptStopGameBang(aPath)
	SETTINGS['stop_game_bang'] = aPath
	UpdateSettings()
end

function ToggleOrientation()
	if SETTINGS['orientation'] == 'vertical' then
		SETTINGS['orientation'] = 'horizontal'
	else
		SETTINGS['orientation'] = 'vertical'
	end
	UpdateSettings()
end

function ToggleHighlighting()
	if SETTINGS['slot_highlight'] == true then
		SETTINGS['slot_highlight'] = false
	else
		SETTINGS['slot_highlight'] = true
	end
	UpdateSettings()
end

function ToggleShowHoursPlayed()
	if SETTINGS['show_hours_played'] == true then
		SETTINGS['show_hours_played'] = false
	else
		SETTINGS['show_hours_played'] = true
	end
	UpdateSettings()
end

function ToggleShowPlatform()
	if SETTINGS['show_platform'] == true then
		SETTINGS['show_platform'] = false
	else
		SETTINGS['show_platform'] = true
	end
	UpdateSettings()
end

function CycleClickAnimation()
	if SETTINGS['orientation'] == 'vertical' then
		if SETTINGS['click_animation'] > #CLICK_ANIMATION_DESCRIPTIONS / 2 then
			SETTINGS['click_animation'] = 0
		else
			SETTINGS['click_animation'] = SETTINGS['click_animation'] + 1
		end
	elseif SETTINGS['orientation'] == 'horizontal' then
		if SETTINGS['click_animation'] < #CLICK_ANIMATION_DESCRIPTIONS / 2 then
			SETTINGS['click_animation'] = #CLICK_ANIMATION_DESCRIPTIONS / 2 + 1
		elseif SETTINGS['click_animation'] >= #CLICK_ANIMATION_DESCRIPTIONS then
			SETTINGS['click_animation'] = 0
		else
			SETTINGS['click_animation'] = SETTINGS['click_animation'] + 1
		end
	end
	UpdateSettings()
end

function CycleHoverAnimation()
	SETTINGS['hover_animation'] = SETTINGS['hover_animation'] + 1
	if SETTINGS['hover_animation'] > #HOVER_ANIMATION_DESCRIPTIONS then
		SETTINGS['hover_animation'] = 0
	end
	UpdateSettings()
end

function ToggleFuzzySearch()
	SETTINGS['fuzzy_search'] = not SETTINGS['fuzzy_search']
	UpdateSettings()
end

function ReadJSON(asPath)
	local f = io.open(asPath, 'r')
	if f ~= nil then
		local json_string = f:read('*a')
		f:close()
		return JSON.decode(json_string)
	end
	return nil
end

function WriteJSON(asPath, atTable)
	local json_string = JSON.encode(atTable)
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

function ReadSettings()
	return ReadJSON(RESOURCES_PATH .. 'settings.json')
end

function WriteSettings(atTable)
	return WriteJSON(RESOURCES_PATH .. 'settings.json', atTable)
end


function RecursiveTableSearch(atTable, asKey)
	for sKey, sValue in pairs(atTable) do
		if sKey == asKey then
			return sValue
		end
	end
	for sKey, sValue in pairs(atTable) do
		local asType = type(sValue)
		if asType == 'table' then
			local tResult = RecursiveTableSearch(sValue, asKey)
			if tResult ~= nil then
				return tResult
			end
		end
	end
	return nil
end

function ParseVDFTable(atTable, anStart)
	anStart = anStart or 1
	assert(type(atTable) == 'table')
	assert(type(anStart) == 'number')
	local tResult = {}
	local sKey = ''
	local sValue = ''
	local i = anStart
	while i <= #atTable do
		sKey = string.match(atTable[i], '^%s*"([^"]+)"%s*$') -- Check for a key prior to a table
		if sKey ~= nil then -- Beginning of a table
			sKey = sKey:lower()
			i = i + 1
			if string.match(atTable[i], '^%s*{%s*$') then
				sValue, i = ParseVDFTable(atTable, (i + 1))
				if sValue == nil and i == nil then
					return nil, nil
				else
					tResult[sKey] = sValue
				end
			else
				print('Error! Failure to parse table at line ' .. tostring(i) .. '(' .. atTable[i] .. ')')
				return nil, nil
			end
		else -- Not the beginning of a table
			sKey = string.match(atTable[i], '^%s*"(.-)"%s*".-"%s*$') -- Check for key and string value pair
			if sKey ~= nil then
				sKey = sKey:lower()
				sValue = string.match(atTable[i], '^%s*".-"%s*"(.-)"%s*$')
				tResult[sKey] = sValue
			else
				if string.match(atTable[i], '^%s*}%s*$') then -- Check if end of an open table
					return tResult, i
				elseif string.match(atTable[i], '^%s*//.*$') then
					-- Comment - Better support is still needed for comments
				else
					sValue = string.match(atTable[i], '^%s*"#base"%s*"(.-)"%s*$')
					if sValue ~= nil then
						-- Base - Needs to be implemented
					else
						print('Error! Failure to parse key-value pair at line ' .. tostring(i) .. '(' .. atTable[i] .. ')')
						return nil, nil
					end
				end
			end
		end
		i = i + 1
	end
	return tResult, i
end

function ParseVDFFile(asPath)
	local fFile = io.open(asPath, 'r')
	local tTable = {}
	if fFile ~= nil then
		for sLine in fFile:lines() do
			table.insert(tTable, sLine)
		end
		fFile:close()
	else
		return nil
	end
	local tResult = ParseVDFTable(tTable)
	if tResult == nil then
		print('Error! Failure to parse' .. asPath)
	end
	return tResult
end
