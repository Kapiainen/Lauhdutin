--###########################################################################################################
-- Code formatting
--###########################################################################################################
--                 -> General
--###########################################################################################################
	-- Max line length: 110 characters
	--   A line that exceeds the maximum number of characters should be made to span multiple lines.
	--   For example the following:
	--
	--     if bSomeCondition and ... and nSomeOtherCondition > 2 then
	--
	--   Would become:
	--
	--     if bSomeCondition
	--        and ...
	--        and nSomeOtherCondition > 2 then
	--
--###########################################################################################################
--                 -> Identifiers
--###########################################################################################################
	-- Identifier formatting
	--   Global variables = All caps with words separated by underscores (e.g. SOME_GLOBAL_VARIABLE)
	--   Local variables = Hungarian notation (e.g. sSomeString)
	--     b = boolean
	--     n = number
	--     s = string
	--     t = table
	--   Function parameters = Hungarian notation prefixed with 'a' (e.g. abSomeBoolean)
	--   Functions = CamelCase (e.g. SomeFunction)
	--   Private functions = Underscore followed by CamelCase (e.g. _SomeFunction)
	--   Nested functions = Lowercase with words separated by underscores
--###########################################################################################################
-- Public
--###########################################################################################################
--        -> Events
--###########################################################################################################
	function OnInitialized()
	-- Called by the Python backend script when it has finished
	-- Show games or display a message that there are no games to show
		local tGames = RESOURCES:ReadGames()
		print(#tGames)
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
			STATUS_MESSAGE:Show('No games to display')
		end
	end

	function OnMouseEnterSkin(abAnimate)
	-- Called when the mouse cursor enters the skin
	-- abAnimate: Whether or not to play an animation to unhide the skin
		SCRIPT:SetUpdateDivider(1)
		if abAnimate then

		else

		end
	end

	function OnMouseLeaveSkin()
	-- Called when the mouse cursor leaves the skin
	-- abAnimate: Whether or not to play an animation to hide the skin
		SCRIPT:SetUpdateDivider(-1)
		SLOT_HIGHLIGHT:Hide(false)
		if T_SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] > 0 then
			
		else
			SKIN:Bang('[!Redraw]')
		end
	end

	function OnMouseEnterSlot(anIndex)
	-- Called when the mouse cursor enters a slot
	-- anIndex: The index of the slot in question (1-indexed)
		SLOT_HIGHLIGHT:MoveTo(anIndex)
		SLOT_HIGHLIGHT:Show(true)
	end

	function OnMouseLeaveSlot(anIndex)
	-- Called when the mouse cursor leaves a slot
	-- anIndex: The index of the slot in question (1-indexed)
		--SLOT:Unhighlight(anIndex)
	end

	function OnLeftClickSlot(anIndex)
	-- Called when a slot is left-mouse clicked
	-- anIndex: The index of the slot in question (1-indexed)
		--PROCESS_MONITOR:Start()
		--If EXECUTE
		--If HIDE
		--If UNHIDE
	end

	function OnMiddleClickSlot(anIndex)
	-- Called when a slot is middle-mouse clicked
	-- anIndex: The index of the slot in question (1-indexed)
		SLOT_SUBMENU:MoveTo(anIndex)
		SLOT_SUBMENU:Show(true)
	end

	function OnLeaveSlotSubmenu()
	-- Called when the mouse cursor leaves the slot submenu
		SLOT_SUBMENU:Hide(true)
	end

	function OnMiddleClickSlotSubmenu()
	-- Called when the slot submenu is middle-mouse clicked
		SLOT_SUBMENU:Hide(true)
	end

	function OnScrollSlots(anDirection)
	-- Called when the list of games is scrolled
	-- anDirection: Positive value -> Upwards, Negative value -> Downwards
		local nSlotCount = tonumber(T_SETTINGS[SETTING_KEYS.SLOT_COUNT])
		local nScrollIndex = N_SCROLL_INDEX
		if #T_FILTERED_GAMES > nSlotCount then
			if anDirection > 0 then
				if nScrollIndex == 1 then
					return
				end
				nScrollIndex = nScrollIndex - 1
				if nScrollIndex < 1 then
					nScrollIndex = 1
				end
				print("Scrolling up")
			elseif anDirection < 0 then
				local nUpperLimit = #T_FILTERED_GAMES + 1 - nSlotCount
				if nScrollIndex == nUpperLimit then
					return
				end
				nScrollIndex = nScrollIndex + 1
				if nScrollIndex > nUpperLimit then
					nScrollIndex = nUpperLimit
				end
				print("Scrolling down")
			end
		end
		N_SCROLL_INDEX = nScrollIndex
	end

	function OnApplyFilter(asPattern)
		if asPattern == '' then
			OnClearFilter()
		else
			asPattern = STRING:Trim(asPattern:lower())
		end
		OnDismissFilterInput()
	end

	function OnDismissFilterInput()

	end

	function OnClearFilter()

	end

	function OnProcessStarted()
		print("Process started")
		ExecuteStartingBangs()
	end

	function OnProcessTerminated()
		print("Process terminated")
		PROCESS_MONITOR:Stop()
		if T_RECENTLY_LAUNCHED_GAME == nil then
			return
		end
		local hoursPlayed = os.difftime(os.time(), T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.LASTPLAYED]) / 3600
		T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.HOURS_TOTAL] = hoursPlayed
														  + T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.HOURS_TOTAL]
		WriteGames()
		if PopulateSlots() then
			Redraw()
		end
		ExecuteStoppingBangs()
		T_RECENTLY_LAUNCHED_GAME = nil
	end

	function OnToggleHideGames()
		if N_ACTION_STATE == ACTION_STATES.HIDE then
			SKIN:Bang('[!SetVariable "TitleToggleHideGames" "Start hiding games"]')
			N_ACTION_STATE = ACTION_STATES.EXECUTE
		else
			SKIN:Bang('[!SetVariable "TitleToggleHideGames" "Stop hiding games"]')
			if N_ACTION_STATE == ACTION_STATES.UNHIDE then
				SKIN:Bang('[!SetVariable "TitleToggleUnhideGames" "Start unhiding games"]')
			end
			N_ACTION_STATE = ACTION_STATES.HIDE
		end
	end

	function OnToggleUnhideGames()
		if N_ACTION_STATE == ACTION_STATES.UNHIDE then
			SKIN:Bang('[!SetVariable "TitleToggleUnhideGames" "Start unhiding games"]')
			N_ACTION_STATE = ACTION_STATES.EXECUTE
		else
			SKIN:Bang('[!SetVariable "TitleToggleUnhideGames" "Stop unhiding games"]')
			if N_ACTION_STATE == ACTION_STATES.HIDE then
				SKIN:Bang('[!SetVariable "TitleToggleHideGames" "Start hiding games"]')
			end
			N_ACTION_STATE = ACTION_STATES.UNHIDE
		end
	end

	function OnFinishedEditingNotes()
	-- Called by '\Backend\EditNotes.py'
		local tEditedGame = RESOURCES:ReadJSON('Temp\\notes_temp.json')
		if tEditedGame ~= nil then
			function update_game(atEditedGame, atTableOfGames)
				for i, tGame in ipairs(atTableOfGames) do
					if tGame[GAME_KEYS.NAME] == atEditedGame[GAME_KEYS.NAME] then
						tGame[GAME_KEYS.NOTES] = atEditedGame[GAME_KEYS.NOTES]
						RESOURCES:WriteGames()
						return true
					end
				end
				return false
			end
			if update_game(tEditedGame, T_ALL_GAMES) then
				return
			elseif update_game(tEditedGame, T_NOT_INSTALLED_GAMES) then
				return
			elseif update_game(tEditedGame, T_HIDDEN_GAMES) then
				return
			end
		end
	end

	function OnFinishedEditingTags()
	-- Called by '\Backend\EditTags.py'
		local tEditedGame = RESOURCES:ReadJSON('Temp\\tags_temp.json')
		if tEditedGame ~= nil then
			function update_game(atEditedGame, atTableOfGames)
				for i, tGame in ipairs(atTableOfGames) do
					if tGame[GAME_KEYS.NAME] == atEditedGame[GAME_KEYS.NAME] then
						tGame[GAME_KEYS.TAGS] = atEditedGame[GAME_KEYS.TAGS]
						RESOURCES:WriteGames()
						return true
					end
				end
				return false
			end
			if update_game(tEditedGame, T_ALL_GAMES) then
				return
			elseif update_game(tEditedGame, T_NOT_INSTALLED_GAMES) then
				return
			elseif update_game(tEditedGame, T_HIDDEN_GAMES) then
				return
			end
		end
	end

	function OnFinishedManualProcessOverride(anIndex, asProcessName)
	-- Called by 'ProcessOverrideInput' measure
		local tGame = T_FILTERED_GAMES[N_SCROLL_INDEX + anIndex - 1]
		if tGame == nil then
			return
		end
		if asProcessName == nil or asProcessName == '' then
			tGame[GAME_KEYS.PROCESS_OVERRIDE] = nil
		else
			tGame[GAME_KEYS.PROCESS_OVERRIDE] = asProcessName
		end
		RESOURCES:WriteGames()
	end

	function OnOpenSettings()

	end

	function OnOpenShortcutsFolder()

	end

	function OnOpenShortcutBannersFolder()

	end

	function OnShowUninstalled()

	end

	function OnShowHidden()

	end
--###########################################################################################################
-- Private
--###########################################################################################################
--         -> State update and rendering
--###########################################################################################################
	function Update()
	-- Called regularly (every ~16 ms) by Rainmeter when the mouse is on the skin
		if #T_SLOT_ANIMATION_QUEUE > 0 then
		-- If there are animations do play, then redraw
			local nSlotIndex = 1
			while nSlotIndex <= SETTINGS.SLOT_COUNT do
				local tAnimation = SLOT_ANIMATION_QUEUE[nSlotIndex]
				if tAnimation ~= nil then
					if tAnimation.nFrame > 0 then
						tAnimation.fAnimation(nSlotIndex, tAnimation.nFrame)
						tAnimation.nFrame = tAnimation.nFrame - 1
					else
						SLOT_ANIMATION_QUEUE[nSlotIndex] = nil
					end
				end
				nSlotIndex = nSlotIndex + 1
			end
			Redraw()
		elseif N_LAST_DRAWN_SCROLL_INDEX ~= N_SCROLL_INDEX then
		-- If scroll index has changed, then redraw
			SLOT_SUBMENU:Hide(false)
			if PopulateSlots() then
				N_LAST_DRAWN_SCROLL_INDEX = N_SCROLL_INDEX
				Redraw()
			end
		elseif N_UPDATES_TO_SKIP > 0 then
			N_UPDATES_TO_SKIP = N_UPDATES_TO_SKIP - 1
		elseif N_UPDATES_TO_SKIP <= 0 then
		-- Redraw once every second that the mouse is on the skin
			Redraw()
			N_UPDATES_TO_SKIP = 124
		end
	end

	function Redraw()
		print("Redraw")
		SKIN:Bang('[!Redraw]')
	end

	function PopulateSlots()
		if T_FILTERED_GAMES == nil then
			return false
		end
		local nSlotCount = tonumber(T_SETTINGS[SETTING_KEYS.SLOT_COUNT])
		local j = N_SCROLL_INDEX
		for i = 1, nSlotCount do -- Iterate through each slot.
			if j > 0 and j <= #T_FILTERED_GAMES then -- If the scroll index, 'j', is a valid index in the table 'T_FILTERED_GAMES'
				if RESOURCES:BannerExists(T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH]) then
					SKIN:Bang(
						'[!SetVariable SlotName' .. i .. ' ""]'
						.. '[!SetVariable SlotImage' .. i .. ' "#@#Banners\\' .. T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH] .. '"]'
					)
				else
					SKIN:Bang(
						'[!SetVariable SlotName' .. i .. ' "' .. T_FILTERED_GAMES[j][GAME_KEYS.NAME] .. '"]'
						.. '[!SetVariable SlotImage' .. i .. ' ""]'
					)
				end
				if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] then
					if N_ACTION_STATE == ACTION_STATES.EXECUTE then
						if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_HOURS_PLAYED] and T_FILTERED_GAMES[j][GAME_KEYS.HOURS_TOTAL] then
							local totalHoursPlayed = T_FILTERED_GAMES[j][GAME_KEYS.HOURS_TOTAL]
							local hoursPlayed = math.floor(totalHoursPlayed)
							local minutesPlayed = math.floor((totalHoursPlayed - hoursPlayed) * 60)
							if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
								SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Install via ' .. GetPlatformDescription(T_FILTERED_GAMES[j]) .. '#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
							elseif T_FILTERED_GAMES[j][GAME_KEYS.INVALID_PATH] == true then
								SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Invalid path#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
							else
								if T_SETTINGS["show_platform"] then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "' .. GetPlatformDescription(T_FILTERED_GAMES[j]) .. '#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
								else
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
								end								
							end
						else
							if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
								SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Install via ' .. GetPlatformDescription(T_FILTERED_GAMES[j]) .. '#CRLF##CRLF##CRLF##CRLF##CRLF#"]')
							elseif T_FILTERED_GAMES[j][GAME_KEYS.INVALID_PATH] == true then
								SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Invalid path#CRLF##CRLF##CRLF##CRLF##CRLF#"]')
							else
								if T_SETTINGS["show_platform"] then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "' .. GetPlatformDescription(T_FILTERED_GAMES[j]) .. '#CRLF##CRLF##CRLF##CRLF##CRLF#"]')
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
					elseif N_ACTION_STATE == ACTION_STATES.HIDE then
						SKIN:Bang(
							'[!SetVariable "SlotHighlightMessage' .. i .. '" "Hide"]'
							.. '[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightHide.png"]'
						)
					elseif N_ACTION_STATE == ACTION_STATES.UNHIDE then
						SKIN:Bang(
							'[!SetVariable "SlotHighlightMessage' .. i .. '" "Unhide"]'
							.. '[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightUnhide.png"]'
						)
					end
				end
			else -- Slot has no game to show.
				if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] then
					SKIN:Bang(
						'[!SetVariable SlotImage' .. i .. ' ""]'
						.. '[!SetVariable SlotName' .. i .. ' ""]'
						.. '[!SetVariable "SlotHighlightMessage' .. i .. '" ""]'
					)
				else
					SKIN:Bang(
						'[!SetVariable SlotImage' .. i .. ' ""]'
						.. '[!SetVariable SlotName' .. i .. ' ""]'
					)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] then
				SKIN:Bang('[!UpdateMeterGroup "SlotHighlight' .. i .. '"]')
			end
			j = j + 1
		end
		SKIN:Bang('[!UpdateMeterGroup Slots]')
		return true
	end
--###########################################################################################################
--         -> Initialization
--###########################################################################################################
	function Initialize()
	-- Called when the skin is loaded
		local sResourcesPath = SKIN:GetVariable('@')
		JSON = dofile(sResourcesPath .. 'Dependencies\\json4lua\\json.lua')
		STRING = dofile(sResourcesPath .. 'Frontend\\String.lua')
		InitializeComponents(sResourcesPath)
		T_SETTINGS = RESOURCES:ReadSettings()
		InitializeEnums(sResourcesPath)
		InitializeStateVariables()
		InitializeConstants()
		-- Start the Python backend script
		OnInitialized() -- Debug
	end

	function InitializeComponents(asResourcesPath)
		SCRIPT = InitializeScript()
		RESOURCES = InitializeResources(asResourcesPath)
		TOOLBAR = InitializeToolbar()
		STATUS_MESSAGE = InitializeStatusMessage()
		SLOT_SUBMENU = InitializeSlotSubmenu()
		SORT = InitializeSort()
		PROCESS_MONITOR = InitializeProcessMonitor()
		SLOT_HIGHLIGHT = InitializeSlotHighlight()
	end

	function InitializeScript()
		return {
			sMeasureName = 'LauhdutinScript',
			SetUpdateDivider = function (self, anValue)
				SKIN:Bang(
					'[!SetOption "' .. self.sMeasureName .. '" "UpdateDivider" "' .. anValue .. '"]'
					.. '[!UpdateMeasure "' .. self.sMeasureName .. '"]'
				)
			end
		}
	end

	function InitializeResources(asResourcesPath)
		return {
			sResourcesPath = asResourcesPath,
			FileExists = function (self, asPath)
				local f = io.open(self.sResourcesPath .. asPath, 'r')
				if f ~= nil then
					f:close()
					return true
				end
				return false
			end,
			BannerExists = function (self, asPath)
				return self:FileExists('Banners\\' .. asPath)
			end,
			ReadJSON = function (self, asPath)
				local f = io.open(self.sResourcesPath .. asPath, 'r')
				if f ~= nil then
					local json_string = f:read('*a')
					f:close()
					return JSON.decode(json_string)
				end
				return nil
			end,
			WriteJSON = function (self, asPath, atTable)
				local json_string = JSON.encode(atTable)
				if json_string == nil then
					return false
				end
				local f = io.open(self.sResourcesPath .. asPath, 'w')
				if f ~= nil then
					f:write(json_string)
					f:close()
					return true
				end
				return false
			end,
			ReadSettings = function (self)
				return self:ReadJSON('settings.json')
			end,
			WriteSettings = function (self, atTable)
				return self:WriteJSON('settings.json', atTable)
			end,
			ReadGames = function (self)
				return self:ReadJSON('games.json')
			end,
			WriteGames = function (self) --TODO: vararg parameter?
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
				return self:WriteJSON('games.json', tTable)
			end
		}
	end

	function InitializeToolbar()
		return {
			bForciblyVisible = false,
			Show = function (self, abForce)
			-- 
			-- abForce: 
				abForce = abForce or false
				-- If skin not visible, then return
				if abForce then
					self.bForciblyVisible = true
				end
				-- If reverse sort, then show appropriate icon
				SKIN:Bang(
					'[!ShowMeterGroup Toolbar]'
					.. '[!Redraw]'
				)
			end,
			Hide = function (self, abForce)
			-- 
			-- abForce: 
				abForce = abForce or false
				-- If skin not visible, then return
				if self.bForciblyVisible and not abForce then
					return
				end
				if abForce then
					self.bForciblyVisible = false
				end
				SKIN:Bang(
					'[!HideMeterGroup Toolbar]'
					.. '[!Redraw]'
				)
			end,
		}
	end

	function InitializeStatusMessage()
		return {
			Show = function (self, asMessage)
			--
			-- asMessage: 
				SKIN:Bang(
					'[!SetVariable Message ' .. asMessage .. ']'
					.. '[!ShowMeterGroup Message]'
					.. '[!Redraw]'
				)
			end,
			Hide = function (self)
			--
			-- asMessage: 
				SKIN:Bang(
					'[!HideMeterGroup Message]'
					.. '[!Redraw]'
				)
			end
		}
	end

	function InitializeSlotSubmenu()
		return {
			MoveTo = function (self, anIndex)
				anIndex = anIndex or 1
				if T_SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
					SKIN:Bang(
						'[!SetOption "SlotSubmenuIcon1" "X" "(#SlotWidth# / 6 - 15)"]'
						.. '[!SetOption "SlotSubmenuBackground" "X" "' .. (T_SETTINGS[SETTING_KEYS.SLOT_WIDTH]
						   - T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] / 1.1) / 2 .. '"]'
						.. '[!SetOption "SlotSubmenuBackground" "Y"' .. T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT]
						   * (anIndex - 1) + (T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT]
						   - T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] / 1.1) / 2 .. '"]'
					)
				else --horizontal
					SKIN:Bang(
						'[!SetOption "SlotSubmenuIcon1" "X" "(' .. T_SETTINGS[SETTING_KEYS.SLOT_WIDTH]
						* (anIndex - 1) .. '+ #SlotWidth# / 6 - 15)"]'
						.. '[!SetOption "SlotSubmenuBackground" "X" "' .. T_SETTINGS[SETTING_KEYS.SLOT_WIDTH]
						   * (anIndex - 1) + (T_SETTINGS[SETTING_KEYS.SLOT_WIDTH]
						   - T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] / 1.1) / 2 .. '"]'
						.. '[!SetOption "SlotSubmenuBackground" "Y"' .. (T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT]
						   - T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] / 1.1) / 2 .. '"]'
					)
				end
				SKIN:Bang(
					'[!SetVariable "SlotSubmenuIndex" "' .. anIndex .. '"]'
					.. '[!UpdateMeterGroup "SlotSubmenu"]'
				)
			end,
			Show = function (self, abRedraw)
				abRedraw = abRedraw or false
				SKIN:Bang('[!ShowMeterGroup "SlotSubmenu"]')
				if abRedraw then
					SKIN:Bang('[!Redraw]')
				end
			end,
			Hide = function (self, abRedraw)
				abRedraw = abRedraw or false
				SKIN:Bang('[!HideMeterGroup "SlotSubmenu"]')
				if abRedraw then
					SKIN:Bang('[!Redraw]')
				end
			end,
			EditNotes = function (self, anIndex)
				local tGame = self:_GetGame(anIndex)
				if tGame == nil then
					return
				end
				RESOURCES:WriteJSON('Temp\\notes_temp.json', tGame)
				SKIN:Bang(
					'["#Python#" "#@#Backend\\EditNotes.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"]'
				)
				self:Hide(true)
			end,
			EditTags = function (self, anIndex)
				local tGame = self:_GetGame(anIndex)
				if tGame == nil then
					return
				end
				RESOURCES:WriteJSON('Temp\\tags_temp.json', tGame)
				SKIN:Bang(
					'["#Python#" "#@#Backend\\EditTags.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"]'
				)
				self:Hide(true)
			end,
			ToggleBangs = function (self, anIndex)
				local tGame = self:_GetGame(anIndex)
				if tGame == nil then
					return
				end
				if tGame[GAME_KEYS.IGNORES_BANGS] ~= true then
					tGame[GAME_KEYS.IGNORES_BANGS] = true
				else
					tGame[GAME_KEYS.IGNORES_BANGS] = nil
				end
				RESOURCES:WriteGames()
				self:Hide(true)
			end,
			EditProcess = function (self, anIndex)
				local tGame = self:_GetGame(anIndex)
				if tGame == nil then
					return
				end
				local sDefaultProcess = ''
				if tGame[GAME_KEYS.PROCESS_OVERRIDE] ~= nil then
					sDefaultProcess = tGame[GAME_KEYS.PROCESS_OVERRIDE]
				end
				SKIN:Bang(
					'[!SetOption "ProcessOverrideInput" "DefaultValue" "' .. sDefaultProcess .. '"]'
					.. '[!UpdateMeasure "ProcessOverrideInput"]'
					.. '[!CommandMeasure "ProcessOverrideInput" "ExecuteBatch 1"]'
				)
				self:Hide(true)
			end,
			ToggleVisibility = function (self, anIndex)
				local tGame = self:_GetGame(anIndex)
				if tGame == nil then
					return
				end
				function move_game_from_to(aGame, aFrom, aTo)
					for i = 1, #aFrom do
						if aFrom[i] == aGame then
							table.insert(aTo, table.remove(aFrom, i))
							return true
						end
					end
					return false
				end
				--Toggle flag and move to the appropriate table
				if tGame[GAME_KEYS.HIDDEN] == true then --Unhide game
					
					tGame[GAME_KEYS.HIDDEN] = false
					if not move_game_from_to(tGame, T_HIDDEN_GAMES, T_ALL_GAMES) then
						move_game_from_to(tGame, T_HIDDEN_GAMES, T_NOT_INSTALLED_GAMES)
					end
				else --Hide game
					tGame[GAME_KEYS.HIDDEN] = true
					if not move_game_from_to(tGame, T_ALL_GAMES, T_HIDDEN_GAMES) then
						move_game_from_to(tGame, T_NOT_INSTALLED_GAMES, T_HIDDEN_GAMES)
					end
				end
				--Remove from filtered games
				for i = 1, #T_FILTERED_GAMES do
					if T_FILTERED_GAMES[i] == tGame then
						table.remove(T_FILTERED_GAMES, i)
						break
					end
				end
				RESOURCES:WriteGames()
				PopulateSlots()
				self:Hide(true)
			end,
			_GetGame = function (self, anIndex)
				if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES == 0 then
					return nil
				end
				return T_FILTERED_GAMES[N_SCROLL_INDEX + anIndex - 1]
			end
		}
	end

	function InitializeSort()
		return {
			Alphabetically = function (self, atFirst, atSecond)
				if atFirst[GAME_KEYS.NAME]:lower():gsub(':', ' ')
				   < atSecond[GAME_KEYS.NAME]:lower():gsub(':', ' ') then
					return true
				else
					return false
				end
			end,
			LastPlayed = function (self, atFirst, atSecond)
				local nFirst = tonumber(atFirst[GAME_KEYS.LASTPLAYED])
				local nSecond = tonumber(atSecond[GAME_KEYS.LASTPLAYED])
				if nFirst > nSecond then
					return true
				elseif nFirst == nSecond then
					return self:Alphabetically(atFirst, atSecond)
				else
					return false
				end
			end,
			HoursPlayed = function (self, atFirst, atSecond)
				local nFirst = tonumber(atFirst[GAME_KEYS.HOURS_TOTAL])
				local nSecond = tonumber(atSecond[GAME_KEYS.HOURS_TOTAL])
				if nFirst > nSecond then
					return true
				elseif nFirst == nSecond then
					return self:Alphabetically(atFirst, atSecond)
				else
					return false
				end
			end
		}
	end

	function InitializeProcessMonitor()
		return {
			sMeasureName = 'ProcessMonitor',
			Start = function (self, asProcessName)
				SKIN:Bang(
					'[!SetOption "' .. self.sMeasureName .. '" "UpdateDivider" "160"]'
					.. '[!SetOption "' .. self.sMeasureName .. '" "ProcessName" "' .. asProcessName .. '"]'
					.. '[!UpdateMeasure "ProcessMonitor"]'
				)
			end,
			Stop = function (self)
				SKIN:Bang(
					'[!SetOption "' .. self.sMeasureName .. '" "UpdateDivider" "-1"]'
					.. '[!UpdateMeasure "ProcessMonitor"]'
				)
			end
		}
	end

	function InitializeSlotHighlight()
		return {
			MoveTo = function (self, anIndex)
				if T_SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
					SKIN:Bang(
						'[!SetOption "SlotHighlightBackground" "Y" "' .. (anIndex - 1)
						* T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] .. '"]'
					)
				else
					SKIN:Bang(
						'[!SetOption "SlotHighlightBackground" "X" "' .. (anIndex - 1)
						* T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] .. '"]'
					)
				end
				SKIN:Bang('[!UpdateMeterGroup "SlotHighlight"]')
			end,
			Show = function (self, abRedraw)
				abRedraw = abRedraw or false
				SKIN:Bang('[!ShowMeterGroup "SlotHighlight"]')
				if abRedraw then
					SKIN:Bang('[!Redraw]')
				end
			end,
			Hide = function (self, abRedraw)
				abRedraw = abRedraw or false
				SKIN:Bang('[!HideMeterGroup "SlotHighlight"]')
				if abRedraw then
					SKIN:Bang('[!Redraw]')
				end
			end
		}
	end

	function InitializeEnums(asResourcesPath)
		local enums = dofile(asResourcesPath .. 'Frontend\\Enums.lua')
		SETTING_KEYS = enums.SETTING_KEYS
		INITIALIZATION_STATES = enums.INITIALIZATION_STATES
		VISIBILITY_STATES = enums.VISIBILITY_STATES
		ACTION_STATES = enums.ACTION_STATES
		ANIMATION_STATES = enums.ANIMATION_STATES
		GAME_KEYS = enums.GAME_KEYS
		PLATFORMS = enums.PLATFORMS
	end

	function InitializeStateVariables()
		T_SLOT_ANIMATION_QUEUE = {}
		N_ACTION_STATE = 0
		N_UPDATES_TO_SKIP = 0
		N_LAST_DRAWN_SCROLL_INDEX = -1
		N_SCROLL_INDEX = 1
		T_ALL_GAMES = {}
		T_FILTERED_GAMES = {}
		T_HIDDEN_GAMES = {}
		T_NOT_INSTALLED_GAMES = {}
	end

	function InitializeConstants()
		PLATFORM_DESCRIPTIONS = {
			"Steam",
			"Steam",
			"GOG Galaxy",
			"",
			"",
			"Blizzard App"
		}
	end
--###########################################################################################################
--         -> Functionality
--###########################################################################################################
--                          -> Bangs
--###########################################################################################################
	function ExecuteStartingBangs()
		print("Executing starting bangs")
	end

	function ExecuteStoppingBangs()
		print("Executing stopping bangs")
		--if T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.IGNORES_BANGS] ~= true and T_SETTINGS[SETTING_KEYS.BANGS_STOPPING] ~= nil and T_SETTINGS[SETTING_KEYS.BANGS_STOPPING] ~= '' then
		--	SKIN:Bang((T_SETTINGS[SETTING_KEYS.BANGS_STOPPING]:gsub('`', '"'))) -- The extra set of parentheses are used to just use the first return value of gsub
		--end
	end
--###########################################################################################################
--                          -> Filtering
--###########################################################################################################
	function FilterBy(asPattern)
		if asPattern == '' then
			T_FILTERED_GAMES = ClearFilter(T_ALL_GAMES)
			--Sort()
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

	function FilterPlatform(atTable, asPattern, asTag, anPlatform)
		local tResult = {}
		asPattern = asPattern:sub(#asTag + 1)
		if StartsWith(asPattern, 'i') then --platform:installed
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.NOT_INSTALLED] ~= true then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'u') then --platform:uninstalled
			for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.NOT_INSTALLED] == true then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'a') then --platform:all
			for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform then
					table.insert(tResult, game)
				end
			end
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'p') then --platform:played
			for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] > 0 then
					table.insert(tResult, game)
				end
			end
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] > 0 then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'n') then --platform:not played
			for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] <= 0 then
					table.insert(tResult, game)
				end
			end
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] <= 0 then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] <= 0 then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'f') then --platform:false
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] ~= anPlatform then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] ~= anPlatform and game[GAME_KEYS.NOT_INSTALLED] ~= true then
						table.insert(tResult, game)
					end
				end
			end
		end
		return tResult
	end

	function Filter(atTable, asPattern)
		if atTable == nil then
			return
		end
		local tResult = {}
		if StartsWith(asPattern, 'steam:') then
			tResult = FilterPlatform(atTable, asPattern, 'steam:', PLATFORM.STEAM)
		elseif StartsWith(asPattern, 'galaxy:') then
			tResult = FilterPlatform(atTable, asPattern, 'galaxy:', PLATFORM.GOG_GALAXY)
		elseif StartsWith(asPattern, 'battlenet:') then
			tResult = FilterPlatform(atTable, asPattern, 'battlenet:', PLATFORM.BATTLENET)
		elseif StartsWith(asPattern, 'tags:') then
			asPattern = asPattern:sub(6)
			for i, game in ipairs(atTable) do
				if game[GAME_KEYS.TAGS] ~= nil then
					for sKey, sValue in pairs(game[GAME_KEYS.TAGS]) do
						if sValue:lower():find(asPattern) then
							table.insert(tResult, game)
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
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.NOT_INSTALLED] ~= true then
							table.insert(tResult, game)
						end
					end
				end				
			elseif StartsWith(asPattern, 'f') then
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResult, game)
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.NOT_INSTALLED] == true then
							table.insert(tResult, game)
						end
					end
				end	
			elseif StartsWith(asPattern, 'a') then
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResult, game)
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResult, game)
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						table.insert(tResult, game)
					end
				end	
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
			elseif StartsWith(asPattern, 'a') then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					table.insert(tResult, game)
				end
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResult, game)
				end
			end
		elseif StartsWith(asPattern, 'games:') then
			asPattern = asPattern:sub(7)
			if StartsWith(asPattern, 'a') then
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResult, game)
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResult, game)
				end
				for i, game in ipairs(T_HIDDEN_GAMES) do
					table.insert(tResult, game)
				end
			end	
		elseif StartsWith(asPattern, 'random:') then
			asPattern = asPattern:sub(8)
			local tResultR = {}
			if StartsWith(asPattern, 'a') then
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResultR, game)
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResultR, game)
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						table.insert(tResultR, game)
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])	
			elseif StartsWith(asPattern, 's') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.STEAM then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.STEAM then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.PLATFORM] == PLATFORM.STEAM then
							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			elseif StartsWith(asPattern, 'g') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.GOG_GALAXY then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.GOG_GALAXY then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.PLATFORM] == PLATFORM.GOG_GALAXY then
							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			elseif StartsWith(asPattern, 'b') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.BATTLENET then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.BATTLENET then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.PLATFORM] == PLATFORM.BATTLENET then
							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			elseif StartsWith(asPattern, 'p') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
 						if game[GAME_KEYS.HOURS_TOTAL] > 0 then
 							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			elseif StartsWith(asPattern, 'n') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] <= 0 then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] <= 0 then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
 						if game[GAME_KEYS.HOURS_TOTAL] <= 0 then
 							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			else
				table.insert(tResult, atTable[math.random(1, #atTable)])
			end		
		elseif StartsWith(asPattern, 'played:') then
			asPattern = asPattern:sub(8)
			if StartsWith(asPattern, 't') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResult, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResult, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
 						if game[GAME_KEYS.HOURS_TOTAL] > 0 then
 							table.insert(tResult, game)
						end
					end
				end
			elseif StartsWith(asPattern, 'f') then	
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] == 0 then
						table.insert(tResult, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] == 0 then
						table.insert(tResult, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
 						if game[GAME_KEYS.HOURS_TOTAL] == 0 then
 							table.insert(tResult, game)
						end
					end
				end
			else
				for i, game in ipairs(atTable) do
					if game[GAME_KEYS.HOURS_TOTAL] == 0 then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'shortcuts:') then
			asPattern = asPattern:sub(11)
			for i, game in ipairs(atTable) do
				if game[GAME_KEYS.PLATFORM_OVERRIDE] ~= nil
				   and game[GAME_KEYS.PLATFORM_OVERRIDE]:lower():find(asPattern) then
					table.insert(tResult, game)
				end
			end
		else
			if T_SETTINGS[SETTING_KEYS.FUZZY_SEARCH] == true then
				local rankings = {}
				local perfectMatches = {}
				for i, game in ipairs(atTable) do
					score = FuzzySearch(asPattern, game[GAME_KEYS.NAME])
					if score > 0 then
						table.insert(rankings, {["score"]=score, ["game"]=game})
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
				for i, game in ipairs(atTable) do
					if game[GAME_KEYS.NAME]:lower():find(asPattern) then
						table.insert(tResult, game)
					end
				end
			end
		end
		return tResult, true
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
--###########################################################################################################
--                          -> Sorting
--###########################################################################################################
--###########################################################################################################
--         -> Animations
--###########################################################################################################
--###########################################################################################################
-- End of refactoring
--###########################################################################################################
--[[
-- OLD VERSION
function Initialize()
	B_ANIMATING = false
	B_INITIALIZED = false
	B_SKIN_VISIBLE = true
	json = dofile(SKIN:GetVariable('@') .. 'Dependencies\\json4lua\\json.lua')
	S_PATH_RESOURCES = SKIN:GetVariable('@')
	S_VDF_SERIALIZING_INDENTATION = ''
	T_SETTINGS = ReadSettings()
	if T_SETTINGS == nil then
		SKIN:Bang(
			'[!SetOption StatusMessage Text "Load Settings.ini and save settings."]'
			.. '[!UpdateMeterGroup Status]'
			.. '[!ShowMeterGroup Status]'
			.. '[!Redraw]'
		)
		return
	end
	SETTING_KEYS = dofile(SKIN:GetVariable('@') .. 'Frontend\\SettingsEnum.lua')
	for i=1, tonumber(T_SETTINGS[SETTING_KEYS.SLOT_COUNT]) do
		SKIN:Bang(
			'[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightPlay.png"]'
			.. '[!HideMeterGroup "SlotHighlight' .. i .. '"]'
		)
	end
	N_LAUNCH_STATE = 0
	T_LAUNCH_STATES = {
		LAUNCH = 0,
		HIDE = 1,
		UNHIDE = 2
	}
	T_RECENTLY_LAUNCHED_GAME = nil
	N_SORT_STATE = 0 --0 = alphabetically, 1 = most recently played
	if T_SETTINGS[SETTING_KEYS.SORT_STATE] then
		N_SORT_STATE = tonumber(T_SETTINGS[SETTING_KEYS.SORT_STATE]) - 1
		CycleSort()
	end
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
		IGNORES_BANGS = "ignoresbangs",
		INVALID_PATH = "invalidpatherror",
		LASTPLAYED = "lastplayed",
		NAME = "title",
		NOTES = "notes",
		NOT_INSTALLED = "notinstalled",
		PATH = "path",
		PLATFORM = "platform",
		PLATFORM_OVERRIDE = "platformoverride",
		PROCESS = "process",
		PROCESS_OVERRIDE = "processoverride",
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
		"Blizzard App"
	}
	B_FORCE_TOOLBAR = false
	HideToolbar()
	B_REVERSE_SORT = false
	SKIN:Bang('[!HideMeter "ToolbarButtonSortReverseIndicator"]')
	N_LAST_DRAWN_SCROLL_INDEX = -1
	HideSlotSubmenu(false)
	if T_SETTINGS ~= nil then
		SKIN:Bang(
			'[!SetOption StatusMessage Text "Initializing backend..."]'
			.. '[!UpdateMeterGroup Status]'
			.. '[!ShowMeterGroup Status]'
			.. '[!Redraw]'
		)
		SKIN:Bang('"#Python#" "#@#Backend\\GetGames.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"')
	else
		SKIN:Bang(
			'[!SetOption StatusMessage Text "Failed to load settings..."]'
			.. '[!UpdateMeterGroup Status]'
			.. '[!ShowMeterGroup Status]'
			.. '[!Redraw]'
		)
	end
end

-- Called once after Initialize() has been called. Runs Backend\GetGames.py.
function Update()
	if N_LAST_DRAWN_SCROLL_INDEX ~= N_SCROLL_INDEX then
		HideSlotSubmenu(false)
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
		SKIN:Bang(
			'[!SetOption StatusMessage Text "No games to display"]'
			.. '[!UpdateMeterGroup Status]'
			.. '[!ShowMeterGroup Status]'
		)
	end
	PopulateSlots()
	B_INITIALIZED = true
end

function StartClickAnimation(asType)
	if B_ANIMATING then
		return
	end
	B_ANIMATING = true
	SKIN:Bang('[!CommandMeasure "ClickAnimation" "Execute ' .. asType .. '"]')
end

function StopAnimating()
	B_ANIMATING = false
end

function SlideSkinIn()
	if B_SKIN_VISIBLE or B_ANIMATING then
		return
	end
	B_ANIMATING = true
	B_SKIN_VISIBLE = true
	SKIN:Bang('[!CommandMeasure "SkinAnimation" "Execute 1"]')
end
--not B_INITIALIZED or B_FORCE_TOOLBAR
function SlideSkinOut()
	if not B_INITIALIZED or B_FORCE_TOOLBAR or not B_SKIN_VISIBLE
	   or T_SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 0 or B_ANIMATING then
		return
	end
	B_ANIMATING = true
	B_SKIN_VISIBLE = false
	SKIN:Bang('[!CommandMeasure "SkinAnimation" "Execute 2"]')
end

function AnimateSkin(anFrame)
	--print(anFrame)
	if anFrame < 1 or anFrame > 8 then
		return
	end
	local nFactor = nil
	if anFrame == 8 then
		nFactor = 0
	elseif anFrame == 3 or anFrame == 5 then
		nFactor = -1 / 1.8
	elseif anFrame == 2 or anFrame == 6 then
		nFactor = -1 / 4
	elseif anFrame == 1 or anFrame == 7 then
		nFactor = -1 / 20
	elseif anFrame == 4 then
		nFactor = -1
	end
	if nFactor == nil then
		return
	end
	if T_SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
		if T_SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 1 then
			SetSlotsXPosition(T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] * nFactor)
		elseif T_SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 2 then
			SetSlotsXPosition(T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] * nFactor * -1)
		end
	else --horizontal
		if T_SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 3 then
			SetSlotsYPosition(T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] * nFactor)
		elseif T_SETTINGS[SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 4 then
			SetSlotsYPosition(T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] * nFactor * -1)
		end
	end
	SKIN:Bang('[!Redraw]')
end

function SetSlotsXPosition(anValue)
	for i = 1, tonumber(T_SETTINGS[SETTING_KEYS.SLOT_COUNT]) do
		SKIN:Bang(
			'[!SetOption "SlotText' .. i .. '" "X" "' .. anValue
			+ T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] / 2 .. '"]'
			.. '[!SetOption "SlotBanner' .. i .. '" "X" "' .. anValue .. '"]'
			.. '[!SetOption "SlotHighlightBackground' .. i .. '" "X" "' .. anValue .. '"]'
		)
	end
	SKIN:Bang(
		'[!UpdateMeterGroup "Slots"]'
		.. '[!UpdateMeterGroup "SlotHighlights"]'
		.. '[!SetOption "SlotBackground" "X" "' .. anValue .. '"]'
		.. '[!UpdateMeter "SlotBackground"]'
		.. '[!SetOption "ToolbarEnabler" "X" "' .. anValue .. '"]'
		.. '[!UpdateMeter "ToolbarEnabler"]'
	)
end

function SetSlotsYPosition(anValue)
	for i = 1, tonumber(T_SETTINGS[SETTING_KEYS.SLOT_COUNT]) do
		SKIN:Bang(
			'[!SetOption "SlotText' .. i .. '" "Y" "' .. anValue
			+ T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] / 2 .. '"]'
			.. '[!SetOption "SlotBanner' .. i .. '" "Y" "' .. anValue .. '"]'
			.. '[!SetOption "SlotHighlightBackground' .. i .. '" "Y" "' .. anValue .. '"]'
		)
	end
	SKIN:Bang(
		'[!UpdateMeterGroup "Slots"]'
		.. '[!UpdateMeterGroup "SlotHighlights"]'
		.. '[!SetOption "SlotBackground" "Y" "' .. anValue .. '"]'
		.. '[!UpdateMeter "SlotBackground"]'
		.. '[!SetOption "ToolbarEnabler" "Y" "' .. anValue .. '"]'
		.. '[!UpdateMeter "ToolbarEnabler"]'
	)
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

	function FilterPlatform(atTable, asPattern, asTag, anPlatform)
		local tResult = {}
		asPattern = asPattern:sub(#asTag + 1)
		if StartsWith(asPattern, 'i') then --platform:installed
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.NOT_INSTALLED] ~= true then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'u') then --platform:uninstalled
			for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.NOT_INSTALLED] == true then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'a') then --platform:all
			for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform then
					table.insert(tResult, game)
				end
			end
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'p') then --platform:played
			for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] > 0 then
					table.insert(tResult, game)
				end
			end
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] > 0 then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'n') then --platform:not played
			for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] <= 0 then
					table.insert(tResult, game)
				end
			end
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] <= 0 then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] == anPlatform and game[GAME_KEYS.HOURS_TOTAL] <= 0 then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'f') then --platform:false
			for i, game in ipairs(T_ALL_GAMES) do
				if game[GAME_KEYS.PLATFORM] ~= anPlatform then
					table.insert(tResult, game)
				end
			end
			if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					if game[GAME_KEYS.PLATFORM] ~= anPlatform and game[GAME_KEYS.NOT_INSTALLED] ~= true then
						table.insert(tResult, game)
					end
				end
			end
		end
		return tResult
	end

	function Filter(atTable, asPattern)
		if atTable == nil then
			return
		end
		local tResult = {}
		if StartsWith(asPattern, 'steam:') then
			tResult = FilterPlatform(atTable, asPattern, 'steam:', PLATFORM.STEAM)
		elseif StartsWith(asPattern, 'galaxy:') then
			tResult = FilterPlatform(atTable, asPattern, 'galaxy:', PLATFORM.GOG_GALAXY)
		elseif StartsWith(asPattern, 'battlenet:') then
			tResult = FilterPlatform(atTable, asPattern, 'battlenet:', PLATFORM.BATTLENET)
		elseif StartsWith(asPattern, 'tags:') then
			asPattern = asPattern:sub(6)
			for i, game in ipairs(atTable) do
				if game[GAME_KEYS.TAGS] ~= nil then
					for sKey, sValue in pairs(game[GAME_KEYS.TAGS]) do
						if sValue:lower():find(asPattern) then
							table.insert(tResult, game)
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
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.NOT_INSTALLED] ~= true then
							table.insert(tResult, game)
						end
					end
				end				
			elseif StartsWith(asPattern, 'f') then
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResult, game)
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.NOT_INSTALLED] == true then
							table.insert(tResult, game)
						end
					end
				end	
			elseif StartsWith(asPattern, 'a') then
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResult, game)
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResult, game)
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						table.insert(tResult, game)
					end
				end	
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
			elseif StartsWith(asPattern, 'a') then
				for i, game in ipairs(T_HIDDEN_GAMES) do
					table.insert(tResult, game)
				end
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResult, game)
				end
			end
		elseif StartsWith(asPattern, 'games:') then
			asPattern = asPattern:sub(7)
			if StartsWith(asPattern, 'a') then
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResult, game)
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResult, game)
				end
				for i, game in ipairs(T_HIDDEN_GAMES) do
					table.insert(tResult, game)
				end
			end	
		elseif StartsWith(asPattern, 'random:') then
			asPattern = asPattern:sub(8)
			local tResultR = {}
			if StartsWith(asPattern, 'a') then
				for i, game in ipairs(T_ALL_GAMES) do
					table.insert(tResultR, game)
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResultR, game)
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						table.insert(tResultR, game)
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])	
			elseif StartsWith(asPattern, 's') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.STEAM then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.STEAM then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.PLATFORM] == PLATFORM.STEAM then
							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			elseif StartsWith(asPattern, 'g') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.GOG_GALAXY then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.GOG_GALAXY then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.PLATFORM] == PLATFORM.GOG_GALAXY then
							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			elseif StartsWith(asPattern, 'b') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.BATTLENET then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.PLATFORM] == PLATFORM.BATTLENET then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
						if game[GAME_KEYS.PLATFORM] == PLATFORM.BATTLENET then
							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			elseif StartsWith(asPattern, 'p') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
 						if game[GAME_KEYS.HOURS_TOTAL] > 0 then
 							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			elseif StartsWith(asPattern, 'n') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] <= 0 then
						table.insert(tResultR, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] <= 0 then
						table.insert(tResultR, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
 						if game[GAME_KEYS.HOURS_TOTAL] <= 0 then
 							table.insert(tResultR, game)
						end
					end
				end
				table.insert(tResult, tResultR[math.random(1, #tResultR)])
			else
				table.insert(tResult, atTable[math.random(1, #atTable)])
			end		
		elseif StartsWith(asPattern, 'played:') then
			asPattern = asPattern:sub(8)
			if StartsWith(asPattern, 't') then
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResult, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResult, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
 						if game[GAME_KEYS.HOURS_TOTAL] > 0 then
 							table.insert(tResult, game)
						end
					end
				end
			elseif StartsWith(asPattern, 'f') then	
				for i, game in ipairs(T_ALL_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] == 0 then
						table.insert(tResult, game)
					end
				end
				for i, game in ipairs(T_NOT_INSTALLED_GAMES) do
					if game[GAME_KEYS.HOURS_TOTAL] == 0 then
						table.insert(tResult, game)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
					for i, game in ipairs(T_HIDDEN_GAMES) do
 						if game[GAME_KEYS.HOURS_TOTAL] == 0 then
 							table.insert(tResult, game)
						end
					end
				end
			else
				for i, game in ipairs(atTable) do
					if game[GAME_KEYS.HOURS_TOTAL] == 0 then
						table.insert(tResult, game)
					end
				end
			end
		elseif StartsWith(asPattern, 'shortcuts:') then
			asPattern = asPattern:sub(11)
			for i, game in ipairs(atTable) do
				if game[GAME_KEYS.PLATFORM_OVERRIDE] ~= nil
				   and game[GAME_KEYS.PLATFORM_OVERRIDE]:lower():find(asPattern) then
					table.insert(tResult, game)
				end
			end
		else
			if T_SETTINGS[SETTING_KEYS.FUZZY_SEARCH] == true then
				local rankings = {}
				local perfectMatches = {}
				for i, game in ipairs(atTable) do
					score = FuzzySearch(asPattern, game[GAME_KEYS.NAME])
					if score > 0 then
						table.insert(rankings, {["score"]=score, ["game"]=game})
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
				for i, game in ipairs(atTable) do
					if game[GAME_KEYS.NAME]:lower():find(asPattern) then
						table.insert(tResult, game)
					end
				end
			end
		end
		return tResult, true
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
		T_SETTINGS[SETTING_KEYS.SORT_STATE] = tostring(N_SORT_STATE)
		WriteSettings(T_SETTINGS)
		SKIN:Bang(
			'[!SetOption "ToolbarButtonSort" "ImageName" "#@#Icons\\Sort' .. N_SORT_STATE .. '.png"]'
			.. '[!UpdateMeterGroup Toolbar]')
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

	function GetPlatformDescription(atGame)
		if atGame ~= nil then
			if atGame[GAME_KEYS.PLATFORM] == 3 or atGame[GAME_KEYS.PLATFORM] == 4 then
				if atGame[GAME_KEYS.PLATFORM_OVERRIDE] ~= nil then
					return atGame[GAME_KEYS.PLATFORM_OVERRIDE]
				end
			end
			return PLATFORM_DESCRIPTION[atGame[GAME_KEYS.PLATFORM]+1]
		end
		return ''
	end

	function PopulateSlots()
		if T_FILTERED_GAMES ~= nil then
			local nSlotCount = tonumber(T_SETTINGS[SETTING_KEYS.SLOT_COUNT])
			local j = N_SCROLL_INDEX
			for i = 1, nSlotCount do -- Iterate through each slot.
				if j > 0 and j <= #T_FILTERED_GAMES then -- If the scroll index, 'j', is a valid index in the table 'T_FILTERED_GAMES'
					if BannerExists(T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH]) then
						SKIN:Bang(
							'[!SetVariable SlotName' .. i .. ' ""]'
							.. '[!SetVariable SlotImage' .. i .. ' "#@#Banners\\' .. T_FILTERED_GAMES[j][GAME_KEYS.BANNER_PATH] .. '"]'
						)
					else
						SKIN:Bang(
							'[!SetVariable SlotName' .. i .. ' "' .. T_FILTERED_GAMES[j][GAME_KEYS.NAME] .. '"]'
							.. '[!SetVariable SlotImage' .. i .. ' ""]'
						)
					end
					if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] then
						if N_LAUNCH_STATE == T_LAUNCH_STATES.LAUNCH then
							if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT_HOURS_PLAYED] and T_FILTERED_GAMES[j][GAME_KEYS.HOURS_TOTAL] then
								local totalHoursPlayed = T_FILTERED_GAMES[j][GAME_KEYS.HOURS_TOTAL]
								local hoursPlayed = math.floor(totalHoursPlayed)
								local minutesPlayed = math.floor((totalHoursPlayed - hoursPlayed) * 60)
								if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Install via ' .. GetPlatformDescription(T_FILTERED_GAMES[j]) .. '#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
								elseif T_FILTERED_GAMES[j][GAME_KEYS.INVALID_PATH] == true then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Invalid path#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
								else
									if T_SETTINGS["show_platform"] then
										SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "' .. GetPlatformDescription(T_FILTERED_GAMES[j]) .. '#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
									else
										SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "#CRLF##CRLF##CRLF##CRLF##CRLF#' .. hoursPlayed .. ' hours ' .. minutesPlayed .. ' minutes played"]')
									end								
								end
							else
								if T_FILTERED_GAMES[j][GAME_KEYS.NOT_INSTALLED] == true then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Install via ' .. GetPlatformDescription(T_FILTERED_GAMES[j]) .. '#CRLF##CRLF##CRLF##CRLF##CRLF#"]')
								elseif T_FILTERED_GAMES[j][GAME_KEYS.INVALID_PATH] == true then
									SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "Invalid path#CRLF##CRLF##CRLF##CRLF##CRLF#"]')
								else
									if T_SETTINGS["show_platform"] then
										SKIN:Bang('[!SetVariable "SlotHighlightMessage' .. i .. '" "' .. GetPlatformDescription(T_FILTERED_GAMES[j]) .. '#CRLF##CRLF##CRLF##CRLF##CRLF#"]')
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
							SKIN:Bang(
								'[!SetVariable "SlotHighlightMessage' .. i .. '" "Hide"]'
								.. '[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightHide.png"]'
							)
						elseif N_LAUNCH_STATE == T_LAUNCH_STATES.UNHIDE then
							SKIN:Bang(
								'[!SetVariable "SlotHighlightMessage' .. i .. '" "Unhide"]'
								.. '[!SetOption "SlotHighlight' .. i .. '" "ImageName" "#@#Icons\\SlotHighlightUnhide.png"]'
							)
						end
					end
				else -- Slot has no game to show.
					if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] then
						SKIN:Bang(
							'[!SetVariable SlotImage' .. i .. ' ""]'
							.. '[!SetVariable SlotName' .. i .. ' ""]'
							.. '[!SetVariable "SlotHighlightMessage' .. i .. '" ""]'
						)
					else
						SKIN:Bang(
							'[!SetVariable SlotImage' .. i .. ' ""]'
							.. '[!SetVariable SlotName' .. i .. ' ""]'
						)
					end
				end
				if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] then
					SKIN:Bang('[!UpdateMeterGroup "SlotHighlight' .. i .. '"]')
				end
				j = j + 1
			end
		end
		SKIN:Bang(
			'[!UpdateMeterGroup Slots]'
			.. '[!Redraw]'
		)
	end

	function Scroll(asDirection)
		local nSlotCount = tonumber(T_SETTINGS[SETTING_KEYS.SLOT_COUNT])
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
						if tGame[GAME_KEYS.PROCESS_OVERRIDE] ~= nil then
							StartMonitoringProcess(tGame[GAME_KEYS.PROCESS_OVERRIDE])
						elseif tGame[GAME_KEYS.PLATFORM] == PLATFORM.STEAM then
							--Monitor Steam Overlay process by default
							StartMonitoringProcess('GameOverlayUI.exe')
						elseif tGame[GAME_KEYS.PLATFORM] == PLATFORM.BATTLENET then
							--Always use the value of GAME_KEYS.PROCESS
							StartMonitoringProcess(tGame[GAME_KEYS.PROCESS])
						elseif tGame[GAME_KEYS.PLATFORM] == PLATFORM.WINDOWS_URL_SHORTCUT then
							--Use the value of GAME_KEYS.PROCESS or don't monitor at all
						else
							local processPath = string.gsub(string.gsub(sPath, "\\", "/"), "//", "/")
							local processName = processPath:reverse()
							processName = processName:match("(exe%p[^\\/:%*?<>|]+)/")
							if processName ~= nil then
								processName = processName:reverse()
								StartMonitoringProcess(processName)
							end
						end
						if tGame[GAME_KEYS.IGNORES_BANGS] ~= true and T_SETTINGS[SETTING_KEYS.BANGS_STARTING] ~= nil and T_SETTINGS[SETTING_KEYS.BANGS_STARTING] ~= '' then
							SKIN:Bang((T_SETTINGS[SETTING_KEYS.BANGS_STARTING]:gsub('`', '"')))
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
		SKIN:Bang(
			'[!SetOption "ProcessMonitor" "UpdateDivider" "160"]'
			.. '[!SetOption "ProcessMonitor" "ProcessName" "' .. asString .. '"]'
			.. '[!UpdateMeasure "ProcessMonitor"]'
		)
	end

	function UpdateTimePlayed()
		if T_RECENTLY_LAUNCHED_GAME ~= nil then
			local hoursPlayed = os.difftime(os.time(), T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.LASTPLAYED]) / 3600
			T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.HOURS_TOTAL] = hoursPlayed + T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.HOURS_TOTAL]
			WriteGames()
			PopulateSlots()
			ExecuteStoppingBang()
			T_RECENTLY_LAUNCHED_GAME = nil
		end
		SKIN:Bang(
			'[!SetOption "ProcessMonitor" "UpdateDivider" "-1"]'
			.. '[!UpdateMeasure "ProcessMonitor"]'
		)
	end

	function ExecuteStoppingBang()
		if T_RECENTLY_LAUNCHED_GAME[GAME_KEYS.IGNORES_BANGS] ~= true and T_SETTINGS[SETTING_KEYS.BANGS_STOPPING] ~= nil and T_SETTINGS[SETTING_KEYS.BANGS_STOPPING] ~= '' then
			SKIN:Bang((T_SETTINGS[SETTING_KEYS.BANGS_STOPPING]:gsub('`', '"'))) -- The extra set of parentheses are used to just use the first return value of gsub
		end
	end

	function Unhighlight(asIndex)
		if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] then
			SKIN:Bang('[!HideMeterGroup "SlotHighlight' .. asIndex .. '"]')
		end
		if T_SETTINGS[SETTING_KEYS.ANIMATION_HOVER] > 0 then
			if T_SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
				SKIN:Bang(
					'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
					.. '[!UpdateMeasure "HoverOffAnimation"]'
					.. '[!CommandMeasure "HoverOffAnimation" "Execute 1"]'
				)
			elseif T_SETTINGS[SETTING_KEYS.ORIENTATION] == 'horizontal' then
				SKIN:Bang(
					'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
					.. '[!UpdateMeasure "HoverOffAnimation"]'
					.. '[!CommandMeasure "HoverOffAnimation" "Execute 2"]'
				)
			end
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
		if T_SETTINGS[SETTING_KEYS.SLOT_HIGHLIGHT] then
			SKIN:Bang('[!ShowMeterGroup "SlotHighlight' .. asIndex ..'"]')
		end
		if T_SETTINGS[SETTING_KEYS.ANIMATION_HOVER] > 0 and not B_ANIMATING and B_SKIN_VISIBLE then
			if T_SETTINGS[SETTING_KEYS.ANIMATION_HOVER] == 1 then
				if T_SETTINGS[SETTING_KEYS.ORIENTATION] == 'vertical' then
					SKIN:Bang(
						'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
						.. '[!UpdateMeasure "HoverOnAnimation"]'
						.. '[!CommandMeasure "HoverOnAnimation" "Execute 1"]'
					)
				elseif T_SETTINGS[SETTING_KEYS.ORIENTATION] == 'horizontal' then
					SKIN:Bang(
						'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
						.. '[!UpdateMeasure "HoverOnAnimation"]'
						.. '[!CommandMeasure "HoverOnAnimation" "Execute 2"]'
					)
				end
			elseif T_SETTINGS[SETTING_KEYS.ANIMATION_HOVER] == 2 then
				SKIN:Bang(
					'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
					.. '[!UpdateMeasure "HoverOnAnimation"]'
					.. '[!CommandMeasure "HoverOnAnimation" "Execute 3"]'
				)
			elseif T_SETTINGS[SETTING_KEYS.ANIMATION_HOVER] == 3 then
				SKIN:Bang(
					'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
					.. '[!UpdateMeasure "HoverOnAnimation"]'
					.. '[!CommandMeasure "HoverOnAnimation" "Execute 4"]'
				)
			end
		end
	end

	function ShowSlotSubmenu(asIndex)
		if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES == 0 then
			return
		end
		local game = T_FILTERED_GAMES[N_SCROLL_INDEX + tonumber(asIndex) - 1]
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
				.. '[!SetOption "SlotSubmenuBackground" "Y"' .. T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] * (tonumber(asIndex) - 1) + (T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] - T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] / 1.1) / 2 .. '"]'
			)
		else --horizontal
			SKIN:Bang(
				'[!SetOption "SlotSubmenuIcon1" "X" "(' .. T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] * (tonumber(asIndex) - 1) .. '+ #SlotWidth# / 6 - 15)"]'
				.. '[!SetOption "SlotSubmenuBackground" "X" "' .. T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] * (tonumber(asIndex) - 1) + (T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] - T_SETTINGS[SETTING_KEYS.SLOT_WIDTH] / 1.1) / 2 .. '"]'
				.. '[!SetOption "SlotSubmenuBackground" "Y"' .. (T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] - T_SETTINGS[SETTING_KEYS.SLOT_HEIGHT] / 1.1) / 2 .. '"]'
			)
		end
		SKIN:Bang(
			'[!SetVariable "SlotSubmenuIndex" "' .. asIndex .. '"]'
			.. '[!SetOption "SlotSubmenuIcon3" "ImageName" "#@#Icons\\' .. bangExecutionIcon ..  '"]'
			.. '[!SetOption "SlotSubmenuIcon5" "ImageName" "#@#Icons\\' .. visibilityIcon ..  '"]'
			.. '[!UpdateMeterGroup "SlotSubmenu"]'
			.. '[!ShowMeterGroup "SlotSubmenu"]'
			.. '[!Redraw]'
		)
	end

	function HideSlotSubmenu(abRedraw)
		if abRedraw then
			SKIN:Bang(
				'[!HideMeterGroup "SlotSubmenu"]'
				.. '[!Redraw]'
			)
		else
			SKIN:Bang('[!HideMeterGroup "SlotSubmenu"]')
		end
	end

	function SlotSubmenuButton(anSlotIndex, anActionID)
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

	function OnFinishedEditingNotes()
		local editedGame = ReadJSON(S_PATH_RESOURCES .. 'Temp\\notes_temp.json')
		if editedGame ~= nil then
			function update_game(aEditedGame, aTableOfGames)
				for i, game in ipairs(aTableOfGames) do
					if game[GAME_KEYS.NAME] == aEditedGame[GAME_KEYS.NAME] then
						game[GAME_KEYS.NOTES] = aEditedGame[GAME_KEYS.NOTES]
						WriteGames()
						return true
					end
				end
				return false
			end
			if update_game(editedGame, T_ALL_GAMES) then
				return
			elseif update_game(editedGame, T_NOT_INSTALLED_GAMES) then
				return
			elseif update_game(editedGame, T_HIDDEN_GAMES) then
				return
			end
		end
	end

	function OnFinishedEditingTags()
		local editedGame = ReadJSON(S_PATH_RESOURCES .. 'Temp\\tags_temp.json')
		if editedGame ~= nil then
			function update_game(aEditedGame, aTableOfGames)
				for i, game in ipairs(aTableOfGames) do
					if game[GAME_KEYS.NAME] == aEditedGame[GAME_KEYS.NAME] then
						game[GAME_KEYS.TAGS] = aEditedGame[GAME_KEYS.TAGS]
						WriteGames()
						return true
					end
				end
				return false
			end
			if update_game(editedGame, T_ALL_GAMES) then
				return
			elseif update_game(editedGame, T_NOT_INSTALLED_GAMES) then
				return
			elseif update_game(editedGame, T_HIDDEN_GAMES) then
				return
			end
		end
	end

	function OnFinishedManualProcessOverride(asIndex, asProcessName)
		local game = T_FILTERED_GAMES[N_SCROLL_INDEX + tonumber(asIndex) - 1]
		if game == nil then
			return
		end
		if asProcessName == nil or asProcessName == '' then
			game[GAME_KEYS.PROCESS_OVERRIDE] = nil
		else
			game[GAME_KEYS.PROCESS_OVERRIDE] = asProcessName
		end
		WriteGames()
	end

-- Error messages
	function ShowMessage(asMessage)
		SKIN:Bang(
			'[!SetVariable Message ' .. asMessage .. ']'
			.. '[!ShowMeterGroup Message]'
			.. '[!Redraw]'
		)
	end

	function HideMessage()
		SKIN:Bang(
			'[!HideMeterGroup Message]'
			.. '[!Redraw]'
		)
	end

-- Toolbar
	function ShowToolbar()
		if not B_SKIN_VISIBLE then
			return
		end
		if B_REVERSE_SORT then
			SKIN:Bang('[!ShowMeter "ToolbarButtonSortReverseIndicator"]')
		end
		SKIN:Bang(
			'[!ShowMeterGroup Toolbar]'
			.. '[!Redraw]'
		)
	end

	function HideToolbar()
		if B_FORCE_TOOLBAR == false then
			if B_REVERSE_SORT then
				SKIN:Bang('[!HideMeter "ToolbarButtonSortReverseIndicator"]')
			end
			SKIN:Bang(
				'[!HideMeterGroup Toolbar]'
				.. '[!Redraw]'
			)
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
--]]