SLOTSUBMENU = {}

function Show(anIndex)
	if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES == 0 then
		return
	end
	local game = T_FILTERED_GAMES[N_SCROLL_INDEX + tonumber(anIndex) - 1]
	if game == nil then
		return
	end
	local visibilityIcon = "SlotSubmenuVisible.png"
	if game[GAME_KEYS.HIDDEN] == true then
		visibilityIcon = "SlotSubmenuHidden.png"
	end
	local bangExecutionIcon = "SlotSubmenuExecutesBangs.png"
	if game[GAME_KEYS.IGNORES_BANGS] == true then
		bangExecutionIcon = "SlotSubmenuIgnoresBangs.png"
	end
	if T_SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
		SKIN:Bang(
			'[!SetOption "SlotSubmenuIcon1" "X" "(#SlotWidth# / 6 - 15)"]'
			.. '[!SetOption "SlotSubmenuBackground" "X" "' .. (T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] - T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] / 1.1) / 2 .. '"]'
			.. '[!SetOption "SlotSubmenuBackground" "Y"' .. T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] * (tonumber(anIndex) - 1) + (T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] - T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] / 1.1) / 2 .. '"]'
		)
	else --horizontal
		SKIN:Bang(
			'[!SetOption "SlotSubmenuIcon1" "X" "(' .. T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] * (tonumber(anIndex) - 1) .. '+ #SlotWidth# / 6 - 15)"]'
			.. '[!SetOption "SlotSubmenuBackground" "X" "' .. T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] * (tonumber(anIndex) - 1) + (T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] - T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] / 1.1) / 2 .. '"]'
			.. '[!SetOption "SlotSubmenuBackground" "Y"' .. (T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] - T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] / 1.1) / 2 .. '"]'
		)
	end
	SKIN:Bang(
		'[!SetVariable "SlotSubmenuIndex" "' .. anIndex .. '"]'
		.. '[!SetOption "SlotSubmenuIcon3" "ImageName" "#@#Icons\\' .. bangExecutionIcon ..  '"]'
		.. '[!SetOption "SlotSubmenuIcon5" "ImageName" "#@#Icons\\' .. visibilityIcon ..  '"]'
		.. '[!UpdateMeterGroup "SlotSubmenu"]'
		.. '[!ShowMeterGroup "SlotSubmenu"]'
		.. '[!Redraw]'
	)
end

function Hide(abRedraw)
	if abRedraw then
		SKIN:Bang(
			'[!HideMeterGroup "SlotSubmenu"]'
			.. '[!Redraw]'
		)
	else
		SKIN:Bang('[!HideMeterGroup "SlotSubmenu"]')
	end
end

function ClickButton(anSlotIndex, anActionID)
	if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES == 0 then
		return
	end
	local game = T_FILTERED_GAMES[N_SCROLL_INDEX + anSlotIndex - 1]
	if game == nil then
		return
	end
	if anActionID == 1 then --Edit notes
		WriteJSON(S_PATH_RESOURCES .. 'Temp\\notes_temp.json', game)
		SKIN:Bang('"#Python#" "#@#Backend\\EditNotes.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"')
	elseif anActionID == 2 then --Edit tags/categories
		WriteJSON(S_PATH_RESOURCES .. 'Temp\\tags_temp.json', game)
		SKIN:Bang('"#Python#" "#@#Backend\\EditTags.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"')
	elseif anActionID == 3 then --Toggle bangs
		--Toggle flag
		if game[GAME_KEYS.IGNORES_BANGS] ~= true then
			game[GAME_KEYS.IGNORES_BANGS] = true
		else
			game[GAME_KEYS.IGNORES_BANGS] = nil
		end
		WriteGames()
	elseif anActionID == 4 then --Manual override of process to monitor
		--Open InputText field
		local defaultProcess = ''
		if game[GAME_KEYS.PROCESS_OVERRIDE] ~= nil then
			defaultProcess = game[GAME_KEYS.PROCESS_OVERRIDE]
		end
		SKIN:Bang(
			'[!SetOption "ProcessOverrideInput" "DefaultValue" "' .. defaultProcess .. '"]'
			.. '[!UpdateMeasure "ProcessOverrideInput"]'
			.. '[!CommandMeasure "ProcessOverrideInput" "ExecuteBatch 1"]'
		)
	elseif anActionID == 5 then --Toggle hide
		function move_game_from_to(aGame, aFrom, aTo)
			for i = 1, #aFrom do
				if aFrom[i] == aGame then
					table.insert(aTo, table.remove(aFrom, i))
					return true
				end
			end
			return false
		end
		--Toggle flag
		--Move game
		if game[GAME_KEYS.HIDDEN] == true then
			--Unhide game
			game[GAME_KEYS.HIDDEN] = false
			if not move_game_from_to(game, T_HIDDEN_GAMES, T_ALL_GAMES) then
				move_game_from_to(game, T_HIDDEN_GAMES, T_NOT_INSTALLED_GAMES)
			end
		else
			--Hide game
			game[GAME_KEYS.HIDDEN] = true
			if not move_game_from_to(game, T_ALL_GAMES, T_HIDDEN_GAMES) then
				move_game_from_to(game, T_NOT_INSTALLED_GAMES, T_HIDDEN_GAMES)
			end
		end
		--Remove from filtered games
		for i = 1, #T_FILTERED_GAMES do
			if T_FILTERED_GAMES[i] == game then
				table.remove(T_FILTERED_GAMES, i)
				break
			end
		end
		--Write updated 'games.json' to disk
		WriteGames()
		PopulateSlots()
	end
	--Write updated 'games.json' to disk
	HideSlotSubmenu(true)
end