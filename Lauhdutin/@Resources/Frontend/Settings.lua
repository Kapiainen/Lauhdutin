function Initialize()
	RESOURCES_PATH = SKIN:GetVariable('@')
	JSON = dofile(SKIN:GetVariable('@') .. 'Dependencies\\json4lua\\json.lua')
	enums = dofile(SKIN:GetVariable('@') .. 'Frontend\\Enums.lua')
	STRING = dofile(RESOURCES_PATH .. 'Frontend\\String.lua')
	POSITION = InitializeSkin()
	POSITION:UpdateDefaultZPos()
	POSITION:SetZPos(0)
	SETTING_KEYS = enums.SETTING_KEYS
	
	REBUILD_SWITCH = false
	EXECUTE_BANGS_SWITCH = false
	SAVING_SETTINGS = false
	SETTINGS = ReadSettings()
	OLD_SETTINGS = ReadSettings()
	if SETTINGS == nil then
		SETTINGS = {}
	end
	if SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] == nil then
		SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] = 1
	end
	if SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] == nil then
		SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] = 8
	end
	if SETTINGS[SETTING_KEYS.SLOT_COUNT] == nil then
		SETTINGS[SETTING_KEYS.SLOT_COUNT] = SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] * SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS]
	end
	if SETTINGS[SETTING_KEYS.SLOT_WIDTH] == nil then
		SETTINGS[SETTING_KEYS.SLOT_WIDTH] = 321
	end
	if SETTINGS[SETTING_KEYS.SLOT_HEIGHT] == nil then
		SETTINGS[SETTING_KEYS.SLOT_HEIGHT] = 150
	end
	if SETTINGS[SETTING_KEYS.SLOT_BACKGROUND_COLOR] == nil then
		SETTINGS[SETTING_KEYS.SLOT_BACKGROUND_COLOR] = "0,0,0,255"
	end
	if SETTINGS[SETTING_KEYS.SLOT_TEXT_COLOR] == nil then
		SETTINGS[SETTING_KEYS.SLOT_TEXT_COLOR] = "255,255,255,255"
	end
	if SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] == nil then
		SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] = true
	end
	if SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_HOURS_PLAYED] == nil then
		SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_HOURS_PLAYED] = true
	end
	if SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM] == nil then
		SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM] = true
	end
	if SETTINGS[SETTING_KEYS.STEAM_PATH] == nil then
		SETTINGS[SETTING_KEYS.STEAM_PATH] = ""
	end
	if SETTINGS[SETTING_KEYS.STEAM_USERDATAID] == nil then
		SETTINGS[SETTING_KEYS.STEAM_USERDATAID] = ""
	end
	if SETTINGS[SETTING_KEYS.STEAM_PERSONANAME] == nil then
		SETTINGS[SETTING_KEYS.STEAM_PERSONANAME] = "" -- Just used for visuals in the Settings menu
	end
	if SETTINGS[SETTING_KEYS.STEAM_ID64] == nil then
		SETTINGS[SETTING_KEYS.STEAM_ID64] = ""
	end
	if SETTINGS[SETTING_KEYS.STEAM_PARSE_COMMUNITY_PROFILE] == nil then
		SETTINGS[SETTING_KEYS.STEAM_PARSE_COMMUNITY_PROFILE] = true
	end
	if SETTINGS[SETTING_KEYS.BANGS_STARTING] == nil then
		SETTINGS[SETTING_KEYS.BANGS_STARTING] = ""
	end
	if SETTINGS[SETTING_KEYS.BANGS_STOPPING] == nil then
		SETTINGS[SETTING_KEYS.BANGS_STOPPING] = ""
	end
	if SETTINGS[SETTING_KEYS.SORT_STATE] == nil then
		SETTINGS[SETTING_KEYS.SORT_STATE] = "0"
	end
	if SETTINGS[SETTING_KEYS.GOG_GALAXY_PATH] == nil then
		SETTINGS[SETTING_KEYS.GOG_GALAXY_PATH] = "C:\/ProgramData\/GOG.com\/Galaxy"
	end
	if SETTINGS[SETTING_KEYS.BATTLENET_PATH] == nil then
		SETTINGS[SETTING_KEYS.BATTLENET_PATH] = ""
	end
	if SETTINGS[SETTING_KEYS.PYTHON_PATH] == nil then
		SETTINGS[SETTING_KEYS.PYTHON_PATH] = "pythonw"
	end
	if SETTINGS[SETTING_KEYS.ORIENTATION] == nil then
		SETTINGS[SETTING_KEYS.ORIENTATION] = "vertical"
	end
	if SETTINGS[SETTING_KEYS.ANIMATION_CLICK] == nil then
		SETTINGS[SETTING_KEYS.ANIMATION_CLICK] = 0
	end
	CLICK_ANIMATION_DESCRIPTIONS = {
		"Shrink",
		"Shift left",
		"Shift right",
		"Shrink",
		"Shift up",
		"Shift down"
	}
	if SETTINGS[SETTING_KEYS.ANIMATION_HOVER] == nil then
		SETTINGS[SETTING_KEYS.ANIMATION_HOVER] = 0
	end
	HOVER_ANIMATION_DESCRIPTIONS = {
		"Zoom in",
		"Jiggle",
		"Shake"
	}
	if SETTINGS[SETTING_KEYS.FUZZY_SEARCH] == nil then
		SETTINGS[SETTING_KEYS.FUZZY_SEARCH] = true
	end
	if SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == nil then
		SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] = false
	end
	if SETTINGS[SETTING_KEYS.SHOW_NOT_INSTALLED_GAMES] == nil then
		SETTINGS[SETTING_KEYS.SHOW_NOT_INSTALLED_GAMES] = false
	end
	if SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == nil then
		--0 = disabled
		--1 = from the left
		--2 = from the right
		--3 = from above
		--4 = from below
		SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] = 0
	end
	SKIN_SLIDE_ANIMATION_DIRECTION_DESCRIPTIONS = {
		"From the left",
		"From the right",
		"From above",
		"From below"
	}
	if SETTINGS[SETTING_KEYS.EXECUTE_BANGS_BY_DEFAULT] == nil then
		SETTINGS[SETTING_KEYS.EXECUTE_BANGS_BY_DEFAULT] = true
	end
	if SETTINGS[SETTING_KEYS.SET_GAMES_TO_EXECUTE_BANGS] == nil then
		SETTINGS[SETTING_KEYS.SET_GAMES_TO_EXECUTE_BANGS] = true
	end
	if SETTINGS[SETTING_KEYS.ADJUST_ZPOS] == nil then
		SETTINGS[SETTING_KEYS.ADJUST_ZPOS] = true
	end
	if SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM_RUNNING] == nil then
		SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM_RUNNING] = true
	end
	SKIN:Bang('[!HideMeterGroup "Paths"]')
	UpdateSettings()
end

function Update()

end

function WritePythonPath()
	local f = io.open(RESOURCES_PATH .. 'PythonPath.inc', 'w')
	if f ~= nil then
		f:write('[Variables]\nPython="' .. SETTINGS[SETTING_KEYS.PYTHON_PATH] .. '"')
		f:close()
	end
end

function Save()
	if SAVING_SETTINGS then
		return
	end
	SAVING_SETTINGS = true
	if OLD_SETTINGS then
		if OLD_SETTINGS[SETTING_KEYS.PYTHON_PATH] ~= SETTINGS[SETTING_KEYS.PYTHON_PATH] and SETTINGS[SETTING_KEYS.PYTHON_PATH] ~= '' then
			WritePythonPath()
		end
	else
		WritePythonPath()
		REBUILD_SWITCH = true
	end
	if EXECUTE_BANGS_SWITCH == true then
		--Create a backup
		games = ReadJSON(RESOURCES_PATH .. 'games.json')
		if games ~= nil then
			WriteJSON(RESOURCES_PATH .. 'games_backup.json', games)
			if SETTINGS[SETTING_KEYS.SET_GAMES_TO_EXECUTE_BANGS] == true then
				for i, game in ipairs(games) do
					game['ignoresbangs'] = false
				end
			else
				for i, game in ipairs(games) do
					game['ignoresbangs'] = true
				end
			end
			WriteJSON(RESOURCES_PATH .. 'games.json', games)
		end
	end
	SETTINGS[SETTING_KEYS.SLOT_COUNT] = SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] * SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN]
	WriteSettings(SETTINGS)
	SAVING_SETTINGS = false
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

function Exit()
	if SAVING_SETTINGS then
		return
	end
	if OLD_SETTINGS then
		local layout_settings = {SETTING_KEYS.SLOT_ROWS_COLUMNS, SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN, SETTING_KEYS.SLOT_WIDTH, SETTING_KEYS.SLOT_HEIGHT, SETTING_KEYS.SLOT_BACKGROUND_COLOR, SETTING_KEYS.SLOT_TEXT_COLOR, SETTING_KEYS.ORIENTATION, SETTING_KEYS.ANIMATION_CLICK, SETTING_KEYS.ANIMATION_HOVER, SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION}
		for i=1, #layout_settings do
			if OLD_SETTINGS[layout_settings[i]] ~= SETTINGS[layout_settings[i]] then
				REBUILD_SWITCH = true
				break
			end
		end
	end
	if ReadSettings() == nil then
		Save()
	end
	POSITION:ResetZPos()
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
		SKIN:Bang('[!SetOption "SlotCountPerRowColumnStatus" "Text" "' .. tostring(SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN]) .. '"]')
		SKIN:Bang('[!SetOption "SlotCountPerRowColumnInput" "DefaultValue" "' .. SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] ..'"]')
		SKIN:Bang('[!SetOption "SlotRowsColumnsStatus" "Text" "' .. tostring(SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS]) .. '"]')
		SKIN:Bang('[!SetOption "SlotRowsColumnsInput" "DefaultValue" "' .. SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] ..'"]')
		SKIN:Bang('[!SetOption "SlotWidthStatus" "Text" "' .. tostring(SETTINGS[SETTING_KEYS.SLOT_WIDTH]) .. '"]')
		SKIN:Bang('[!SetOption "SlotWidthInput" "DefaultValue" "' .. SETTINGS[SETTING_KEYS.SLOT_WIDTH] ..'"]')
		SKIN:Bang('[!SetOption "SlotHeightStatus" "Text" "' .. tostring(SETTINGS[SETTING_KEYS.SLOT_HEIGHT]) .. '"]')
		SKIN:Bang('[!SetOption "SlotHeightInput" "DefaultValue" "' .. SETTINGS[SETTING_KEYS.SLOT_HEIGHT] ..'"]')
		SKIN:Bang('[!SetOption "SteamPathStatus" "Text" "' .. tostring(SETTINGS[SETTING_KEYS.STEAM_PATH]) .. '"]')
		SKIN:Bang('[!SetOption "SteamPathInput" "DefaultValue" "' .. SETTINGS[SETTING_KEYS.STEAM_PATH] ..'"]')
		SKIN:Bang('[!SetOption "SteamUserdataidStatus" "Text" "' .. tostring(SETTINGS[SETTING_KEYS.STEAM_PERSONANAME]) .. '"]')
		SKIN:Bang('[!SetOption "SteamUserdataidInput" "DefaultValue" "' .. SETTINGS[SETTING_KEYS.STEAM_USERDATAID] ..'"]')
		SKIN:Bang('[!SetOption "GalaxyPathStatus" "Text" "' .. tostring(SETTINGS[SETTING_KEYS.GOG_GALAXY_PATH]) .. '"]')
		SKIN:Bang('[!SetOption "GalaxyPathInput" "DefaultValue" "' .. SETTINGS[SETTING_KEYS.GOG_GALAXY_PATH] ..'"]')
		SKIN:Bang('[!SetOption "BattlenetPathStatus" "Text" "' .. tostring(SETTINGS[SETTING_KEYS.BATTLENET_PATH]) .. '"]')
		SKIN:Bang('[!SetOption "BattlenetPathInput" "DefaultValue" "' .. SETTINGS[SETTING_KEYS.BATTLENET_PATH] ..'"]')
		SKIN:Bang('[!SetOption "PythonPathStatus" "Text" "' .. tostring(SETTINGS[SETTING_KEYS.PYTHON_PATH]) .. '"]')
		SKIN:Bang('[!SetOption "PythonPathInput" "DefaultValue" "' .. SETTINGS[SETTING_KEYS.PYTHON_PATH] ..'"]')
		if SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
			SKIN:Bang('[!SetOption "SkinOrientationStatus" "Text" "Vertical"]')
			if SETTINGS[SETTING_KEYS.ANIMATION_CLICK] > #CLICK_ANIMATION_DESCRIPTIONS / 2 then
				SETTINGS[SETTING_KEYS.ANIMATION_CLICK] = 0
			end
			if SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] > 2 then
				SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] = 0
			end
		else
			SKIN:Bang('[!SetOption "SkinOrientationStatus" "Text" "Horizontal"]')
			if SETTINGS[SETTING_KEYS.ANIMATION_CLICK] <= #CLICK_ANIMATION_DESCRIPTIONS / 2 then
				SETTINGS[SETTING_KEYS.ANIMATION_CLICK] = 0
			end
			if SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] < 3 then
				SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] = 0
			end
		end
		if SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] == true then
			SKIN:Bang('[!SetOption "SlotHighlightingStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "SlotHighlightingStatus" "Text" "Disabled"]')
		end
		if SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_HOURS_PLAYED] == true then
			SKIN:Bang('[!SetOption "ShowHoursPlayedStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "ShowHoursPlayedStatus" "Text" "Disabled"]')
		end
		if SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM] == true then
			SKIN:Bang('[!SetOption "ShowPlatformStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "ShowPlatformStatus" "Text" "Disabled"]')
		end
		if SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM_RUNNING] == true then
			SKIN:Bang('[!SetOption "ShowPlatformRunningStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "ShowPlatformRunningStatus" "Text" "Disabled"]')
		end
		if SETTINGS[SETTING_KEYS.ANIMATION_CLICK] == 0 then
			SKIN:Bang('[!SetOption "ClickAnimationStatus" "Text" "Disabled"]')
		else
			SKIN:Bang('[!SetOption "ClickAnimationStatus" "Text" "' .. CLICK_ANIMATION_DESCRIPTIONS[SETTINGS[SETTING_KEYS.ANIMATION_CLICK]] .. '"]')
		end
		if SETTINGS[SETTING_KEYS.ANIMATION_HOVER] == 0 then
			SKIN:Bang('[!SetOption "HoverAnimationStatus" "Text" "Disabled"]')
		else
			SKIN:Bang('[!SetOption "HoverAnimationStatus" "Text" "' .. HOVER_ANIMATION_DESCRIPTIONS[SETTINGS[SETTING_KEYS.ANIMATION_HOVER]] .. '"]')
		end
		if SETTINGS[SETTING_KEYS.FUZZY_SEARCH] == true then
			SKIN:Bang('[!SetOption "FuzzySearchStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "FuzzySearchStatus" "Text" "Disabled"]')
		end
		if SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
			SKIN:Bang('[!SetOption "HiddenGamesStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "HiddenGamesStatus" "Text" "Disabled"]')
		end		
		if SETTINGS[SETTING_KEYS.SHOW_NOT_INSTALLED_GAMES] == true then
			SKIN:Bang('[!SetOption "NotInstalledGamesStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "NotInstalledGamesStatus" "Text" "Disabled"]')
		end
		if SETTINGS[SETTING_KEYS.STEAM_PARSE_COMMUNITY_PROFILE] == true then
			SKIN:Bang('[!SetOption "SteamProfileStatus" "Text" "Parse"]')
		else
			SKIN:Bang('[!SetOption "SteamProfileStatus" "Text" "Ignore"]')
		end
		if SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 0 then
			SKIN:Bang('[!SetOption "SkinSlideAnimationDirectionStatus" "Text" "Disabled"]')
		else
			SKIN:Bang('[!SetOption "SkinSlideAnimationDirectionStatus" "Text" "' .. SKIN_SLIDE_ANIMATION_DIRECTION_DESCRIPTIONS[SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION]] .. '"]')
		end
		if SETTINGS[SETTING_KEYS.EXECUTE_BANGS_BY_DEFAULT] == true then
			SKIN:Bang('[!SetOption "ExecuteBangsByDefaultStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "ExecuteBangsByDefaultStatus" "Text" "Disabled"]')
		end
		if SETTINGS[SETTING_KEYS.SET_GAMES_TO_EXECUTE_BANGS] == true then
			SKIN:Bang('[!SetOption "ExecuteIgnoreBangsStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "ExecuteIgnoreBangsStatus" "Text" "Disabled"]')
		end
		if SETTINGS[SETTING_KEYS.ADJUST_ZPOS] == true then
			SKIN:Bang('[!SetOption "AdjustZPosStatus" "Text" "Enabled"]')
		else
			SKIN:Bang('[!SetOption "AdjustZPosStatus" "Text" "Disabled"]')
		end
		SKIN:Bang('[!Update]')
		SKIN:Bang('[!Redraw]')
	end
end

function IncrementSlotCountPerRowColumn()
	SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] = SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] + 1
	UpdateSettings()
end

function DecrementSlotCountPerRowColumn()
	if SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] > 1 then
		SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] = SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] - 1
		UpdateSettings()
	end
end

function SetSlotCountPerRowColumn(aValue)
	local numVal = tonumber(aValue)
	if numVal and numVal > 0 then
		SETTINGS[SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN] = numVal
		UpdateSettings()
	end
end

function SetSlotRowsColumns(aValue)
	local numVal = tonumber(aValue)
	if numVal and numVal > 0 then
		SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] = numVal
		UpdateSettings()
	end
end

function IncrementSlotRowsColumns()
	SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] = SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] + 1
	UpdateSettings()
end

function DecrementSlotRowsColumns()
	if SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] > 1 then
		SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] = SETTINGS[SETTING_KEYS.SLOT_ROWS_COLUMNS] - 1
		UpdateSettings()
	end
end

function IncrementSlotWidth()
	SETTINGS[SETTING_KEYS.SLOT_WIDTH] = SETTINGS[SETTING_KEYS.SLOT_WIDTH] + 1
	UpdateSettings()
end

function DecrementSlotWidth()
	if SETTINGS[SETTING_KEYS.SLOT_WIDTH] > 1 then
		SETTINGS[SETTING_KEYS.SLOT_WIDTH] = SETTINGS[SETTING_KEYS.SLOT_WIDTH] - 1
		UpdateSettings()
	end
end

function SetSlotWidth(aValue)
	local numVal = tonumber(aValue)
	if numVal and numVal > 0 then
		SETTINGS[SETTING_KEYS.SLOT_WIDTH] = numVal
		UpdateSettings()
	end
end


function IncrementSlotHeight()
	SETTINGS[SETTING_KEYS.SLOT_HEIGHT] = SETTINGS[SETTING_KEYS.SLOT_HEIGHT] + 1
	UpdateSettings()
end

function DecrementSlotHeight()
	if SETTINGS[SETTING_KEYS.SLOT_HEIGHT] > 1 then
		SETTINGS[SETTING_KEYS.SLOT_HEIGHT] = SETTINGS[SETTING_KEYS.SLOT_HEIGHT] - 1
		UpdateSettings()
	end
end

function SetSlotHeight(aValue)
	local numVal = tonumber(aValue)
	if numVal and numVal > 0 then
		SETTINGS[SETTING_KEYS.SLOT_HEIGHT] = numVal
		UpdateSettings()
	end
end


function RequestSteamPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFolderPathDialog.py" "#PROGRAMPATH#;" "AcceptSteamPath;" "' .. SETTINGS[SETTING_KEYS.STEAM_PATH] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptSteamPath(aPath)
	SETTINGS[SETTING_KEYS.STEAM_PATH] = aPath
	UpdateSettings()
end

function RequestSteamUserdataid()
	local initialDir = ''
	if SETTINGS[SETTING_KEYS.STEAM_PATH] ~= '' then
		initialDir = SETTINGS[SETTING_KEYS.STEAM_PATH] .. '\\userdata'
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
			SETTINGS[SETTING_KEYS.STEAM_USERDATAID] = udid
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
				configPath = SETTINGS[SETTING_KEYS.STEAM_PATH] .. '/userdata/' .. udid .. '/config/localconfig.vdf'
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
			SETTINGS[SETTING_KEYS.STEAM_PERSONANAME] = personaName
			SETTINGS[SETTING_KEYS.STEAM_ID64] = ''
			if personaName ~= '' and SETTINGS[SETTING_KEYS.STEAM_PATH] ~= nil then
				local loginusers = ParseVDFFile(SETTINGS[SETTING_KEYS.STEAM_PATH] .. '/config/loginusers.vdf')
				if loginusers ~= nil then
					local users = loginusers['users']
					if users ~= nil then
						for steamID64, accountTable in pairs(users) do
							if accountTable['personaname'] == personaName then
								SETTINGS[SETTING_KEYS.STEAM_ID64] = steamID64
								break
							end
						end
					end
				end
			end
			if SETTINGS[SETTING_KEYS.STEAM_ID64] == '' then
				print('Lauhdutin: Failed to figure out SteamID64 for ' .. personaName)
			end
			UpdateSettings()
		end
	else
		SETTINGS[SETTING_KEYS.STEAM_USERDATAID] = ''
		SETTINGS[SETTING_KEYS.STEAM_PERSONANAME] = ''
		UpdateSettings()
	end
end

function ToggleSteamProfile()
	SETTINGS[SETTING_KEYS.STEAM_PARSE_COMMUNITY_PROFILE] = not SETTINGS[SETTING_KEYS.STEAM_PARSE_COMMUNITY_PROFILE]
	UpdateSettings()
end

function RequestGalaxyPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFolderPathDialog.py" "#PROGRAMPATH#;" "AcceptGalaxyPath;" "' .. SETTINGS[SETTING_KEYS.GOG_GALAXY_PATH] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptGalaxyPath(aPath)
	SETTINGS[SETTING_KEYS.GOG_GALAXY_PATH] = aPath
	UpdateSettings()
end

function RequestBattlenetPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFolderPathDialog.py" "#PROGRAMPATH#;" "AcceptBattlenetPath;" "' .. SETTINGS[SETTING_KEYS.BATTLENET_PATH] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptBattlenetPath(aPath)
	SETTINGS[SETTING_KEYS.BATTLENET_PATH] = aPath
	UpdateSettings()
end

function RequestPythonPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFilePathDialog.py" "#PROGRAMPATH#;" "AcceptPythonPath;" "' .. SETTINGS[SETTING_KEYS.PYTHON_PATH] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptPythonPath(aPath)
	SETTINGS[SETTING_KEYS.PYTHON_PATH] = aPath
	UpdateSettings()
end

function EditStartGameBang()
	print("Edit start")
	SKIN:Bang('"#Python#" "#@#Backend\\EditBangs.py" "#PROGRAMPATH#;" "#@#;" "true;" "OnFinishedEditingStartGameBang;" "#CURRENTCONFIG#;"')
	--#Python#
end

function OnFinishedEditingStartGameBang()
	print("On finished editing start")
	local f = io.open(RESOURCES_PATH .. 'Temp\\bangs_temp.txt', 'r')
	if f ~= nil then
		contents = f:read('*a')
		f:close()
		SETTINGS[SETTING_KEYS.BANGS_STARTING] = contents
	end
end

--function AcceptStartGameBang(aPath)
--	SETTINGS[SETTING_KEYS.BANGS_STARTING] = aPath
--	UpdateSettings()
--end

function EditStopGameBang()
	print("Edit stop")
	SKIN:Bang('"#Python#" "#@#Backend\\EditBangs.py" "#PROGRAMPATH#;" "#@#;" "false;" "OnFinishedEditingStopGameBang;" "#CURRENTCONFIG#;"')
end

function OnFinishedEditingStopGameBang()
	print("On finished editing stop")
	local f = io.open(RESOURCES_PATH .. 'Temp\\bangs_temp.txt', 'r')
	if f ~= nil then
		contents = f:read('*a')
		f:close()
		SETTINGS[SETTING_KEYS.BANGS_STOPPING] = contents
	end
end

--function AcceptStopGameBang(aPath)
--	SETTINGS[SETTING_KEYS.BANGS_STOPPING] = aPath
--	UpdateSettings()
--end

function ToggleOrientation()
	if SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
		SETTINGS[SETTING_KEYS.ORIENTATION] = 'horizontal'
	else
		SETTINGS[SETTING_KEYS.ORIENTATION] = 'vertical'
	end
	UpdateSettings()
end

function ToggleHighlighting()
	SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] = not SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT]
	UpdateSettings()
end

function ToggleShowHoursPlayed()
	SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_HOURS_PLAYED] = not SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_HOURS_PLAYED]
	UpdateSettings()
end

function ToggleShowPlatform()
	SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM] = not SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM]
	UpdateSettings()
end

function ToggleShowPlatformRunning()
	SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM_RUNNING] = not SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM_RUNNING]
	UpdateSettings()
end

function CycleClickAnimation()
	if SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
		if SETTINGS[SETTING_KEYS.ANIMATION_CLICK] > #CLICK_ANIMATION_DESCRIPTIONS / 2 then
			SETTINGS[SETTING_KEYS.ANIMATION_CLICK] = 0
		else
			SETTINGS[SETTING_KEYS.ANIMATION_CLICK] = SETTINGS[SETTING_KEYS.ANIMATION_CLICK] + 1
		end
	elseif SETTINGS[SETTING_KEYS.ORIENTATION] == 'horizontal' then
		if SETTINGS[SETTING_KEYS.ANIMATION_CLICK] < #CLICK_ANIMATION_DESCRIPTIONS / 2 then
			SETTINGS[SETTING_KEYS.ANIMATION_CLICK] = #CLICK_ANIMATION_DESCRIPTIONS / 2 + 1
		elseif SETTINGS[SETTING_KEYS.ANIMATION_CLICK] >= #CLICK_ANIMATION_DESCRIPTIONS then
			SETTINGS[SETTING_KEYS.ANIMATION_CLICK] = 0
		else
			SETTINGS[SETTING_KEYS.ANIMATION_CLICK] = SETTINGS[SETTING_KEYS.ANIMATION_CLICK] + 1
		end
	end
	UpdateSettings()
end

function CycleHoverAnimation()
	SETTINGS[SETTING_KEYS.ANIMATION_HOVER] = SETTINGS[SETTING_KEYS.ANIMATION_HOVER] + 1
	if SETTINGS[SETTING_KEYS.ANIMATION_HOVER] > #HOVER_ANIMATION_DESCRIPTIONS then
		SETTINGS[SETTING_KEYS.ANIMATION_HOVER] = 0
	end
	UpdateSettings()
end

function ToggleFuzzySearch()
	SETTINGS[SETTING_KEYS.FUZZY_SEARCH] = not SETTINGS[SETTING_KEYS.FUZZY_SEARCH]
	UpdateSettings()
end

function ToggleNotInstalledGames()
	SETTINGS[SETTING_KEYS.SHOW_NOT_INSTALLED_GAMES] = not SETTINGS[SETTING_KEYS.SHOW_NOT_INSTALLED_GAMES]
	UpdateSettings()
end

function ToggleHiddenGames()
	SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] = not SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES]
	UpdateSettings()
end

function CycleSkinSlideAnimationDirection()
	if SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
		if SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] < 2 then
			SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] = SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] + 1
		else
			SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] = 0
		end
	else
		if SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 3 then
			SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] = 4
		elseif SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 0 then
			SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] = 3
		else
			SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] = 0
		end
	end
	UpdateSettings()
end

function ToggleAdjustZPos()
	SETTINGS[SETTING_KEYS.ADJUST_ZPOS] = not SETTINGS[SETTING_KEYS.ADJUST_ZPOS]
	UpdateSettings()
end

function ToggleExecuteBangsByDefault()
	SETTINGS[SETTING_KEYS.EXECUTE_BANGS_BY_DEFAULT] = not SETTINGS[SETTING_KEYS.EXECUTE_BANGS_BY_DEFAULT]
	UpdateSettings()
end

function ToggleExecuteIgnoreBangs()
	SETTINGS[SETTING_KEYS.SET_GAMES_TO_EXECUTE_BANGS] = not SETTINGS[SETTING_KEYS.SET_GAMES_TO_EXECUTE_BANGS]
	EXECUTE_BANGS_SWITCH = true
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

function InitializeSkin()
	return {
		nDefaultZPos = nil,
		sSettingsPath = SKIN:GetVariable('SETTINGSPATH', nil),
		sConfig = SKIN:GetVariable('CURRENTCONFIG', nil),

		UpdateDefaultZPos = function (self)
			if self.sSettingsPath == nil then
				return false
			end
			local f = io.open(self.sSettingsPath .. 'Rainmeter.ini', 'r')
			if f ~= nil then
				local sRainmeterINI = f:read('*a')
				f:close()
				local nStarts, nEnds = sRainmeterINI:find('%[' .. self.sConfig .. '%][^%[]+')
				if nStarts == nil or nEnds == nil then
					return false
				end
				local sConfigSettings = sRainmeterINI:sub(nStarts, nEnds)
				for sLine in STRING:Split(sConfigSettings, '\n') do
					nStarts, nEnds = sLine:find("AlwaysOnTop=")
					if nStarts and nEnds then
						self.nDefaultZPos = tonumber(sLine:sub(nEnds + 1))
						return true
					end
				end
			end
			return false
		end,

		SetZPos = function (self, anValue)
			if anValue >= -2 and anValue <= 2 then
				SKIN:Bang('[!ZPos "' .. anValue .. '"]')
			end
		end,

		ResetZPos = function (self)
			if self.nDefaultZPos ~= nil then
				SKIN:Bang('[!ZPos "' .. self.nDefaultZPos .. '" ]')
			end
		end
	}
end