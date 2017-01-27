function Initialize()
	JSON = dofile(SKIN:GetVariable('@') .. 'Dependencies\\json4lua\\json.lua')
	RESOURCES_PATH = SKIN:GetVariable('@')
	SETTINGS = ReadSettings()
	if SETTINGS == nil then
		SETTINGS = {}
	end
	if SETTINGS['slot_count'] == nil then
		SETTINGS['slot_count'] = 6
	end
	if SETTINGS['slot_width'] == nil then
		SETTINGS['slot_width'] = 418
	end
	if SETTINGS['slot_height'] == nil then
		SETTINGS['slot_height'] = 195
	end
	if SETTINGS['slot_background_color'] == nil then
		SETTINGS['slot_background_color'] = "0,0,0,196"
	end
	if SETTINGS['slot_text_color'] == nil then
		SETTINGS['slot_text_color'] = "255,255,255,255"
	end
	if SETTINGS['steam_path'] == nil then
		SETTINGS['steam_path'] = ""
	end
	if SETTINGS['steam_userdataid'] == nil then
		SETTINGS['steam_userdataid'] = ""
	end
	if SETTINGS['steam_personaname'] == nil then
		SETTINGS['steam_personaname'] = ""
	end
	if SETTINGS['sortstate'] == nil then
		SETTINGS['sortstate'] = "0"
	end
	if SETTINGS['galaxy_path'] == nil then
		SETTINGS['galaxy_path'] = "C:\/ProgramData\/GOG.com\/Galaxy"
	end
	if SETTINGS['python_path'] == nil then
		SETTINGS['python_path'] = "pythonw"
	end
	SKIN:Bang('[!HideMeterGroup "Platform"]')
	UpdateSettings()
end

function Update()
	--SKIN:Bang('"#Python#" "#@#Backend\\GetGames.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"')
end

function Save()
	local old_settings = ReadSettings()
	if old_settings then
		local layout_settings = {'slot_count', 'slot_width', 'slot_height', 'slot_background_color', 'slot_text_color'}
		for i=1, #layout_settings do
			if old_settings[layout_settings[i]] ~= SETTINGS[layout_settings[i]] then
				SKIN:Bang('["#Python#" "#@#Frontend\\BuildSkin.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"]')
				break
			end
		end
		if old_settings['python_path'] ~= SETTINGS['python_path'] and SETTINGS['python_path'] ~= '' then
			local f = io.open(RESOURCES_PATH .. 'PythonPath.inc', 'w')
			if f ~= nil then
				f:write('[Variables]\nPython="' .. SETTINGS['python_path'] .. '"')
				f:close()
			end
		end
	else
		SKIN:Bang('["#Python#" "#@#Frontend\\BuildSkin.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"]')
	end
	WriteSettings(SETTINGS)
end

function Exit()
	SKIN:Bang('[!ActivateConfig #CURRENTCONFIG# "Main.ini"]')
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
		SKIN:Bang('[!SetOption "SlotWidthStatus" "Text" "' .. tostring(SETTINGS['slot_width']) .. '"]')
		SKIN:Bang('[!SetOption "SlotHeightStatus" "Text" "' .. tostring(SETTINGS['slot_height']) .. '"]')
		SKIN:Bang('[!SetOption "SteamPathStatus" "Text" "' .. tostring(SETTINGS['steam_path']) .. '"]')
		SKIN:Bang('[!SetOption "SteamUserdataidStatus" "Text" "' .. tostring(SETTINGS['steam_personaname']) .. '"]')
		SKIN:Bang('[!SetOption "GalaxyPathStatus" "Text" "' .. tostring(SETTINGS['galaxy_path']) .. '"]')
		SKIN:Bang('[!SetOption "PythonPathStatus" "Text" "' .. tostring(SETTINGS['python_path']) .. '"]')
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
	if aPath ~= nil and aPath ~= '' then
		SETTINGS['steam_path'] = aPath
		UpdateSettings()
	end
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
			UpdateSettings()
		end
	end
end

function RequestGalaxyPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFolderPathDialog.py" "#PROGRAMPATH#;" "AcceptGalaxyPath;" "' .. SETTINGS['galaxy_path'] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptGalaxyPath(aPath)
	if aPath ~= nil and aPath ~= '' then
		SETTINGS['galaxy_path'] = aPath
		UpdateSettings()
	end
end

function RequestPythonPath()
	SKIN:Bang('"#Python#" "#@#Frontend\\GenericFilePathDialog.py" "#PROGRAMPATH#;" "AcceptPythonPath;" "' .. SETTINGS['python_path'] .. '"; "#CURRENTCONFIG#;"')
end

function AcceptPythonPath(aPath)
	if aPath ~= nil and aPath ~= '' then
		SETTINGS['python_path'] = aPath
		UpdateSettings()
	end
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