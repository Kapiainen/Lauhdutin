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
	--   Types
	--     b = boolean
	--     c = component
	--     e = enum
	--     n = number
	--     s = string
	--     t = table
	--   Global variables = All caps with words separated by underscores (e.g. SOME_GLOBAL_VARIABLE)
	--   Local variables = Hungarian notation (e.g. sSomeString)
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
		C_STATUS_MESSAGE:Hide()
		local tGames = C_RESOURCES:ReadGames()
		print(#tGames)
		for sKey, tTable in pairs(tGames) do
			if tTable[E_GAME_KEYS.HIDDEN] == true then
				table.insert(T_HIDDEN_GAMES, tTable)
			elseif tTable[E_GAME_KEYS.NOT_INSTALLED] == true then
				table.insert(T_NOT_INSTALLED_GAMES, tTable)
			else
				table.insert(T_ALL_GAMES, tTable)
			end
		end
		if T_ALL_GAMES ~= nil and #T_ALL_GAMES > 0 then
			FilterBy('')
		elseif T_NOT_INSTALLED_GAMES ~= nil and #T_NOT_INSTALLED_GAMES > 0 then
			FilterBy('installed:false')
		elseif T_HIDDEN_GAMES ~= nil and #T_HIDDEN_GAMES > 0 then
			FilterBy('hidden:true')
		else
			C_STATUS_MESSAGE:Show('No games to display')
		end
	end

	function OnShowStatus(asMessage)
		C_STATUS_MESSAGE:Show(asMessage)
	end
--###########################################################################################################
--                  -> Mouse actions
--###########################################################################################################
--                                   -> Skin
--###########################################################################################################
	function OnMouseEnterSkin(abAnimate)
	-- Called when the mouse cursor enters the skin
	-- abAnimate: Whether or not to play an animation to unhide the skin
		C_SCRIPT:SetUpdateDivider(1)
		if abAnimate then

		else

		end
	end

	function OnMouseLeaveSkin()
	-- Called when the mouse cursor leaves the skin
	-- abAnimate: Whether or not to play an animation to hide the skin
		C_SCRIPT:SetUpdateDivider(-1)
		C_SLOT_HIGHLIGHT:Hide(false)
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] > 0 then
			
		else
			Redraw()
		end
	end

	function OnScrollSlots(anDirection)
	-- Called when the list of games is scrolled
	-- anDirection: Positive value -> Upwards, Negative value -> Downwards
		local nSlotCount = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT])
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
--###########################################################################################################
--                                   -> Toolbar
--###########################################################################################################
	function OnMouseEnterToolbar(abForce)
		abForce = abForce or false
		C_SLOT_HIGHLIGHT:Hide()
		C_TOOLBAR:Show(abForce)
	end

	function OnMouseLeaveToolbar(abForce)
		abForce = abForce or false
		C_TOOLBAR:Hide(abForce)
		if C_SLOT_HIGHLIGHT:Update() then
			C_SLOT_HIGHLIGHT:Show()
		end
	end

	function OnApplyFilter(asPattern)
		C_STATUS_MESSAGE:Hide()
		if asPattern == '' then
			FilterBy('')
		else
			FilterBy(asPattern)
		end
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			C_SLOT_HIGHLIGHT:Update()
		end
		C_TOOLBAR:Hide(true)
		if #T_FILTERED_GAMES <= 0 then
			OnShowStatus('No matches')
		end
	end

	function OnDismissFilterInput()
		C_TOOLBAR.bForciblyVisible = false
	end

	function OnClearFilter()
		OnApplyFilter('')
	end

	function OnCycleSorting()
		B_REVERSE_SORT = false
		SKIN:Bang('[!HideMeter "ToolbarButtonSortReverseIndicator"]')
		print(T_SETTINGS[E_SETTING_KEYS.SORT_STATE])
		T_SETTINGS[E_SETTING_KEYS.SORT_STATE] = T_SETTINGS[E_SETTING_KEYS.SORT_STATE] + 1
		if T_SETTINGS[E_SETTING_KEYS.SORT_STATE] > 2 then
			T_SETTINGS[E_SETTING_KEYS.SORT_STATE] = 0
		end
		C_TOOLBAR:UpdateSortingIcon()
		C_RESOURCES:WriteSettings()
		SortGames()
		PopulateSlots()
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			C_SLOT_HIGHLIGHT:Update()
		end
		Redraw()
	end

	function OnReverseSorting()
		B_REVERSE_SORT = not B_REVERSE_SORT
		if B_REVERSE_SORT then
			SKIN:Bang('[!ShowMeter "ToolbarButtonSortReverseIndicator"]')
		else
			SKIN:Bang('[!HideMeter "ToolbarButtonSortReverseIndicator"]')
		end
		local tReversed = {}
		for i, tGame in ipairs(T_FILTERED_GAMES) do
			table.insert(tReversed, 1, tGame)
		end
		T_FILTERED_GAMES = tReversed
		PopulateSlots()
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			C_SLOT_HIGHLIGHT:Update()
		end
		Redraw()
	end
--###########################################################################################################
--                                   -> Slot
--###########################################################################################################
	function OnMouseEnterSlot(anIndex)
	-- Called when the mouse cursor enters a slot
	-- anIndex: The index of the slot in question (1-indexed)
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			C_SLOT_HIGHLIGHT:MoveTo(anIndex)
			if C_SLOT_HIGHLIGHT:Update() then
				C_SLOT_HIGHLIGHT:Show(true)
			end
		end
	end

	function OnMouseLeaveSlot(anIndex)
	-- Called when the mouse cursor leaves a slot
	-- anIndex: The index of the slot in question (1-indexed)
		--SLOT:Unhighlight(anIndex)
	end

	function OnLeftClickSlot(anIndex)
	-- Called when a slot is left-mouse clicked
	-- anIndex: The index of the slot in question (1-indexed)
		--C_PROCESS_MONITOR:Start()
		--If EXECUTE
		--If HIDE
		--If UNHIDE
		if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES <= 0 then
			return
		end
		local tGame = T_FILTERED_GAMES[N_SCROLL_INDEX + anIndex - 1]
		if tGame == nil then
			return
		end
		if N_ACTION_STATE == E_ACTION_STATES.EXECUTE then
			if LaunchGame(tGame) then
				Redraw()
			end
		elseif N_ACTION_STATE == E_ACTION_STATES.HIDE then
			if HideGame(tGame) then
				Redraw()
			end
		elseif N_ACTION_STATE == E_ACTION_STATES.UNHIDE then
			if UnhideGame(tGame) then
				Redraw()
			end
		end
	end

	function OnMiddleClickSlot(anIndex)
	-- Called when a slot is middle-mouse clicked
	-- anIndex: The index of the slot in question (1-indexed)
		if C_SLOT_SUBMENU:MoveTo(anIndex) then
			C_SLOT_SUBMENU:Show(true)
		end
	end
--###########################################################################################################
--                                   -> Slot submenu
--###########################################################################################################
	function OnMiddleClickSlotSubmenu()
	-- Called when the slot submenu is middle-mouse clicked
		C_SLOT_SUBMENU:Hide(true)
	end

	function OnMouseLeaveSlotSubmenu()
	-- Called when the mouse cursor leaves the slot submenu
		C_SLOT_SUBMENU:Hide(true)
	end

	function OnStartEditingNotes()
		C_SLOT_SUBMENU:StartEditingNotes()
	end

	function OnFinishedEditingNotes()
	-- Called by '\Backend\EditNotes.py'
		C_SLOT_SUBMENU:FinishedEditingNotes()
	end

	function OnStartEditingTags()
		C_SLOT_SUBMENU:StartEditingTags()
	end

	function OnFinishedEditingTags()
	-- Called by '\Backend\EditTags.py'
		C_SLOT_SUBMENU:FinishedEditingTags()
	end

	function OnToggleBangs()
		C_SLOT_SUBMENU:ToggleBangs()
	end

	function OnStartEditingProcessOverride()
		C_SLOT_SUBMENU:StartEditingProcessOverride()
	end

	function OnFinishedEditingProcessOverride(asProcessName)
	-- Called by 'ProcessOverrideInput' measure
		C_SLOT_SUBMENU:FinishedEditingProcessOverride(asProcessName)
	end

	function OnToggleVisibility()
		SLOT_SUBMENU:ToggleVisibility()
	end
--###########################################################################################################
--                  -> Context menu actions
--###########################################################################################################
	function OnToggleHideGames()
		if N_ACTION_STATE == E_ACTION_STATES.HIDE then
			SKIN:Bang('[!SetVariable "TitleToggleHideGames" "Start hiding games"]')
			N_ACTION_STATE = E_ACTION_STATES.EXECUTE
		else
			SKIN:Bang('[!SetVariable "TitleToggleHideGames" "Stop hiding games"]')
			if N_ACTION_STATE == E_ACTION_STATES.UNHIDE then
				SKIN:Bang('[!SetVariable "TitleToggleUnhideGames" "Start unhiding games"]')
			end
			N_ACTION_STATE = E_ACTION_STATES.HIDE
		end
	end

	function OnToggleUnhideGames()
		if N_ACTION_STATE == E_ACTION_STATES.UNHIDE then
			SKIN:Bang('[!SetVariable "TitleToggleUnhideGames" "Start unhiding games"]')
			N_ACTION_STATE = E_ACTION_STATES.EXECUTE
		else
			SKIN:Bang('[!SetVariable "TitleToggleUnhideGames" "Stop unhiding games"]')
			if N_ACTION_STATE == E_ACTION_STATES.HIDE then
				SKIN:Bang('[!SetVariable "TitleToggleHideGames" "Start hiding games"]')
			end
			N_ACTION_STATE = E_ACTION_STATES.UNHIDE
		end
	end

	function OnShowNotInstalled()

	end

	function OnShowHidden()

	end
--###########################################################################################################
--                  -> Process monitoring
--###########################################################################################################
	function OnProcessStarted()
		print("Process started")
		ExecuteStartingBangs()
	end

	function OnProcessTerminated()
		print("Process terminated")
		C_PROCESS_MONITOR:Stop()
		if T_RECENTLY_LAUNCHED_GAME == nil then
			return
		end
		local hoursPlayed = os.difftime(os.time(), T_RECENTLY_LAUNCHED_GAME[E_GAME_KEYS.LASTPLAYED]) / 3600
		T_RECENTLY_LAUNCHED_GAME[E_GAME_KEYS.HOURS_TOTAL] = hoursPlayed
														  + T_RECENTLY_LAUNCHED_GAME[E_GAME_KEYS.HOURS_TOTAL]
		C_RESOURCES:WriteGames()
		if PopulateSlots() then
			Redraw()
		end
		ExecuteStoppingBangs()
		T_RECENTLY_LAUNCHED_GAME = nil
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
			if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
				C_SLOT_HIGHLIGHT:Update()
			end
			C_SLOT_SUBMENU:Hide(false)
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
		local nSlotCount = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT])
		local j = N_SCROLL_INDEX
		for i = 1, nSlotCount do -- Iterate through each slot.
			if j > 0 and j <= #T_FILTERED_GAMES then -- If the scroll index, 'j', is a valid index in the table 'T_FILTERED_GAMES'
				if C_RESOURCES:BannerExists(T_FILTERED_GAMES[j][E_GAME_KEYS.BANNER_PATH]) then
					SKIN:Bang(
						'[!SetOption "SlotText' .. i .. '" "Text" ""]'
						.. '[!SetOption "SlotBanner' .. i .. '" "ImageName" "#@#Banners\\'
						.. T_FILTERED_GAMES[j][E_GAME_KEYS.BANNER_PATH] .. '"]'
					)
				else
					SKIN:Bang(
						'[!SetOption "SlotText' .. i .. '" "Text" "'
						.. T_FILTERED_GAMES[j][E_GAME_KEYS.NAME] .. '"]'
						.. '[!SetOption "SlotBanner' .. i .. '" "ImageName" ""]'
					)
				end
			else -- Slot has no game to show.
				SKIN:Bang(
					'[!SetOption "SlotText' .. i .. '" "Text" ""]'
					.. '[!SetOption "SlotBanner' .. i .. '" "ImageName" ""]'
				)
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
		T_SETTINGS = C_RESOURCES:ReadSettings()
		InitializeEnums(sResourcesPath)
		InitializeStateVariables()
		InitializeConstants()
		C_TOOLBAR:UpdateSortingIcon()
		C_TOOLBAR:Hide()
		C_SLOT_HIGHLIGHT:Hide()
		C_STATUS_MESSAGE:Show('Initializing...')
		-- Start the Python backend script
		SKIN:Bang('["#Python#" "#@#Backend\\GetGames.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"]')
		--OnInitialized() -- Debug
	end

	function InitializeComponents(asResourcesPath)
		C_SCRIPT = InitializeScript()
		C_RESOURCES = InitializeResources(asResourcesPath)
		C_TOOLBAR = InitializeToolbar()
		C_STATUS_MESSAGE = InitializeStatusMessage()
		C_SLOT_SUBMENU = InitializeSlotSubmenu()
		C_PROCESS_MONITOR = InitializeProcessMonitor()
		C_SLOT_HIGHLIGHT = InitializeSlotHighlight()
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

			WriteSettings = function (self)
				return self:WriteJSON('settings.json', T_SETTINGS)
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
				if B_REVERSE_SORT then
					SKIN:Bang('[!ShowMeter "ToolbarButtonSortReverseIndicator"]')
				end
				SKIN:Bang('[!ShowMeterGroup Toolbar]')
				Redraw()
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
					'[!HideMeter "ToolbarButtonSortReverseIndicator"]'
					.. '[!HideMeterGroup Toolbar]'
				)
				Redraw()
			end,

			UpdateSortingIcon = function (self, abRedraw)
				abRedraw = abRedraw or false
				SKIN:Bang(
					'[!SetOption "ToolbarButtonSort" "ImageName" "#@#Icons\\Sort'
					.. T_SETTINGS[E_SETTING_KEYS.SORT_STATE] .. '.png"]'
					.. '[!UpdateMeter "ToolbarButtonSort"]'
				)
				if abRedraw then
					Redraw()
				end
			end
		}
	end

	function InitializeStatusMessage()
		return {
			bVisible = false,

			Show = function (self, asMessage)
			--
			-- asMessage: 
				self.bVisible = true
				SKIN:Bang(
					'[!SetOption "StatusMessage" "Text" "' .. asMessage .. '"]'
					.. '[!UpdateMeterGroup "Status"]'
					.. '[!ShowMeterGroup "Status"]'
					.. '[!Redraw]'
				)
			end,

			Hide = function (self)
			--
			-- asMessage: 
				if not self.bVisible then
					return
				end
				SKIN:Bang(
					'[!HideMeterGroup "Status"]'
					.. '[!Redraw]'
				)
			end
		}
	end

	function InitializeSlotSubmenu()
		return {
			nCurrentIndex = 0,

			MoveTo = function (self, anIndex)
				self.nCurrentIndex = anIndex or 1
				local tGame = self:_GetGame()
				if tGame == nil then
					return false
				end
				if T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'vertical' then
					SKIN:Bang(
						'[!SetOption "SlotSubmenuIcon1" "X" "(#SlotWidth# / 6 - 15)"]'
						.. '[!SetOption "SlotSubmenuBackground" "X" "'
						   .. (T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH]
						   - T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH] / 1.1) / 2 .. '"]'
						.. '[!SetOption "SlotSubmenuBackground" "Y"'
						   .. T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT]
						   * (self.nCurrentIndex - 1) + (T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT]
						   - T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT] / 1.1) / 2 .. '"]'
					)
				else --horizontal
					SKIN:Bang(
						'[!SetOption "SlotSubmenuIcon1" "X" "(' .. T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH]
						* (self.nCurrentIndex - 1) .. '+ #SlotWidth# / 6 - 15)"]'
						.. '[!SetOption "SlotSubmenuBackground" "X" "'
						   .. T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH]
						   * (self.nCurrentIndex - 1) + (T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH]
						   - T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH] / 1.1) / 2 .. '"]'
						.. '[!SetOption "SlotSubmenuBackground" "Y"'
						   .. (T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT]
						   - T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT] / 1.1) / 2 .. '"]'
					)
				end
				if tGame[E_GAME_KEYS.IGNORES_BANGS] then
					SKIN:Bang(
						'[!SetOption "SlotSubmenuIcon3" "ImageName" "#@#Icons\\SlotSubmenuIgnoresBangs.png"]'
					)
				else
					SKIN:Bang(
						'[!SetOption "SlotSubmenuIcon3" "ImageName" "#@#Icons\\SlotSubmenuExecutesBangs.png"]'
					)
				end
				if tGame[E_GAME_KEYS.HIDDEN] then
					SKIN:Bang(
						'[!SetOption "SlotSubmenuIcon5" "ImageName" "#@#Icons\\SlotSubmenuHidden.png"]'
					)
				else
					SKIN:Bang(
						'[!SetOption "SlotSubmenuIcon5" "ImageName" "#@#Icons\\SlotSubmenuVisible.png"]'
					)
				end
				SKIN:Bang(
					--'[!SetVariable "SlotSubmenuIndex" "' .. anIndex .. '"]'
					'[!UpdateMeterGroup "SlotSubmenu"]'
				)
				return true
			end,

			Show = function (self, abRedraw)
				abRedraw = abRedraw or false
				SKIN:Bang('[!ShowMeterGroup "SlotSubmenu"]')
				if abRedraw then
					Redraw()
				end
			end,

			Hide = function (self, abRedraw)
				abRedraw = abRedraw or false
				SKIN:Bang('[!HideMeterGroup "SlotSubmenu"]')
				if abRedraw then
					Redraw()
				end
			end,

			StartEditingNotes = function (self)
				local tGame = self:_GetGame()
				if tGame == nil then
					return
				end
				C_RESOURCES:WriteJSON('Temp\\notes_temp.json', tGame)
				SKIN:Bang(
					'["#Python#" "#@#Backend\\EditNotes.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"]'
				)
				self:Hide(true)
			end,

			FinishedEditingNotes = function (self)
				local tEditedGame = C_RESOURCES:ReadJSON('Temp\\notes_temp.json')
				if tEditedGame ~= nil then
					function update_game(atEditedGame, atTableOfGames)
						for i, tGame in ipairs(atTableOfGames) do
							if tGame[E_GAME_KEYS.NAME] == atEditedGame[E_GAME_KEYS.NAME] then
								tGame[E_GAME_KEYS.NOTES] = atEditedGame[E_GAME_KEYS.NOTES]
								C_RESOURCES:WriteGames()
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
			end,

			StartEditingTags = function (self)
				local tGame = self:_GetGame()
				if tGame == nil then
					return
				end
				C_RESOURCES:WriteJSON('Temp\\tags_temp.json', tGame)
				SKIN:Bang(
					'["#Python#" "#@#Backend\\EditTags.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"]'
				)
				self:Hide(true)
			end,

			FinishedEditingTags = function (self)
				local tEditedGame = C_RESOURCES:ReadJSON('Temp\\tags_temp.json')
				if tEditedGame ~= nil then
					function update_game(atEditedGame, atTableOfGames)
						for i, tGame in ipairs(atTableOfGames) do
							if tGame[E_GAME_KEYS.NAME] == atEditedGame[E_GAME_KEYS.NAME] then
								tGame[E_GAME_KEYS.TAGS] = atEditedGame[E_GAME_KEYS.TAGS]
								C_RESOURCES:WriteGames()
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
			end,

			ToggleBangs = function (self)
				local tGame = self:_GetGame()
				if tGame == nil then
					return
				end
				if tGame[E_GAME_KEYS.IGNORES_BANGS] ~= true then
					tGame[E_GAME_KEYS.IGNORES_BANGS] = true
				else
					tGame[E_GAME_KEYS.IGNORES_BANGS] = nil
				end
				C_RESOURCES:WriteGames()
				self:Hide(true)
			end,

			StartEditingProcessOverride = function (self)
				local tGame = self:_GetGame()
				if tGame == nil then
					return
				end
				local sDefaultProcess = ''
				if tGame[E_GAME_KEYS.PROCESS_OVERRIDE] ~= nil then
					sDefaultProcess = tGame[E_GAME_KEYS.PROCESS_OVERRIDE]
				end
				SKIN:Bang(
					'[!SetOption "ProcessOverrideInput" "DefaultValue" "' .. sDefaultProcess .. '"]'
					.. '[!UpdateMeasure "ProcessOverrideInput"]'
					.. '[!CommandMeasure "ProcessOverrideInput" "ExecuteBatch 1"]'
				)
				self:Hide(true)
			end,

			FinishedEditingProcessOverride = function (self, asProcessName)
				local tGame = T_FILTERED_GAMES[N_SCROLL_INDEX + self.nCurrentIndex - 1]
				if tGame == nil then
					return
				end
				if asProcessName == nil or asProcessName == '' then
					tGame[E_GAME_KEYS.PROCESS_OVERRIDE] = nil
				else
					tGame[E_GAME_KEYS.PROCESS_OVERRIDE] = asProcessName
				end
				C_RESOURCES:WriteGames()
			end,

			ToggleVisibility = function (self)
				local tGame = self:_GetGame()
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
				if tGame[E_GAME_KEYS.HIDDEN] == true then --Unhide game
					
					tGame[E_GAME_KEYS.HIDDEN] = false
					if not move_game_from_to(tGame, T_HIDDEN_GAMES, T_ALL_GAMES) then
						move_game_from_to(tGame, T_HIDDEN_GAMES, T_NOT_INSTALLED_GAMES)
					end
				else --Hide game
					tGame[E_GAME_KEYS.HIDDEN] = true
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
				C_RESOURCES:WriteGames()
				PopulateSlots()
				self:Hide(true)
			end,

			_GetGame = function (self)
				if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES == 0 then
					return nil
				end
				return T_FILTERED_GAMES[N_SCROLL_INDEX + self.nCurrentIndex - 1]
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
			nCurrentIndex = 0,

			MoveTo = function (self, anIndex)
				self.nCurrentIndex = anIndex
				if T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'vertical' then
					SKIN:Bang(
						'[!SetOption "SlotHighlightBackground" "Y" "' .. (anIndex - 1)
						* T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT] .. '"]'
					)
				else
					SKIN:Bang(
						'[!SetOption "SlotHighlightBackground" "X" "' .. (anIndex - 1)
						* T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH] .. '"]'
					)
				end
				SKIN:Bang('[!UpdateMeterGroup "SlotHighlight"]')
			end,

			Update = function (self)
				if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES <= 0 then
					self:Hide()
					return false
				end
				local tGame = T_FILTERED_GAMES[N_SCROLL_INDEX + self.nCurrentIndex - 1]
				if tGame == nil then
					self:Hide(true)
					return false
				end
				local sHighlightMessage = ''
				if N_ACTION_STATE == E_ACTION_STATES.EXECUTE then
					if tGame[E_GAME_KEYS.ERROR] then
						SKIN:Bang(
							'[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightError.png"]'
						)
						if tGame[E_GAME_KEYS.INVALID_PATH] then
							sHighlightMessage = 'Invalid path'
						end
					elseif tGame[E_GAME_KEYS.NOT_INSTALLED] then
						SKIN:Bang(
							'[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightInstall.png"]'
						)
						if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM] then
							if tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.STEAM
							   or tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.BATTLENET then
							   sHighlightMessage = 'Install via '
							   					   .. PLATFORM_DESCRIPTIONS[tGame[E_GAME_KEYS.PLATFORM] + 1]
							else
								sHighlightMessage = 'Not installed'
							end
						end
					else
						SKIN:Bang(
							'[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightPlay.png"]'
						)
						if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM] then
							sHighlightMessage = PLATFORM_DESCRIPTIONS[tGame[E_GAME_KEYS.PLATFORM] + 1]
						end
					end
				elseif N_ACTION_STATE == E_ACTION_STATES.HIDE then
					SKIN:Bang('[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightHide.png"]')
				elseif N_ACTION_STATE == E_ACTION_STATES.UNHIDE then
					SKIN:Bang('[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightUnhide.png"]')
				end
				sHighlightMessage = sHighlightMessage .. '#CRLF##CRLF##CRLF##CRLF##CRLF#'
				if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT_HOURS_PLAYED] then
					local nHoursPlayed = math.floor(tGame[E_GAME_KEYS.HOURS_TOTAL])
					if nHoursPlayed == 1 then
						sHighlightMessage = sHighlightMessage .. '1 hour'
					else
						sHighlightMessage = sHighlightMessage .. nHoursPlayed .. ' hours'
					end
				end
				SKIN:Bang('[!SetOption "SlotHighlightText" "Text" "' .. sHighlightMessage .. '"]')
				SKIN:Bang('[!UpdateMeterGroup "SlotHighlight"]')
				return true
			end,

			Show = function (self, abRedraw)
				abRedraw = abRedraw or false
				SKIN:Bang('[!ShowMeterGroup "SlotHighlight"]')
				if abRedraw then
					Redraw()
				end
			end,

			Hide = function (self, abRedraw)
				abRedraw = abRedraw or false
				SKIN:Bang('[!HideMeterGroup "SlotHighlight"]')
				if abRedraw then
					Redraw()
				end
			end
		}
	end

	function InitializeEnums(asResourcesPath)
		local enums = dofile(asResourcesPath .. 'Frontend\\Enums.lua')
		E_SETTING_KEYS = enums.SETTING_KEYS
		E_INITIALIZATION_STATES = enums.INITIALIZATION_STATES
		E_VISIBILITY_STATES = enums.VISIBILITY_STATES
		E_ACTION_STATES = enums.ACTION_STATES
		E_ANIMATION_STATES = enums.ANIMATION_STATES
		E_GAME_KEYS = enums.GAME_KEYS
		E_PLATFORMS = enums.PLATFORMS
		E_SORTING_STATES = enums.SORTING_STATES
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
		T_RECENTLY_LAUNCHED_GAME = nil
		B_REVERSE_SORT = false
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
--                          -> Launching games
--###########################################################################################################
	function LaunchGame(atGame)
		print('Launch: ' .. atGame[E_GAME_KEYS.NAME])
		if atGame[E_GAME_KEYS.ERROR] == true then
			SKIN:Bang(
				'[!Log "Lauhdutin - Error: There is something wrong with ' .. atGame[E_GAME_KEYS.NAME] .. '"]'
			)
			return false
		end
		local sPath = atGame[E_GAME_KEYS.PATH]
		if sPath == nil or sPath == '' then
			return false
		end
		local bInstalling = false
		if atGame[E_GAME_KEYS.NOT_INSTALLED] then -- Install, move to list of all games, and potentially unhide
			bInstalling = true
			if not (atGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.STEAM
			   or atGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.BATTLENET) then
				return false
			end
			if not InstallGame(atGame) then
				UnhideGame(atGame)
			end
		elseif atGame[E_GAME_KEYS.HIDDEN] then -- Unhide and launch
			UnhideGame(atGame)
		end
		atGame[E_GAME_KEYS.LASTPLAYED] = os.time()
		C_RESOURCES:WriteGames()
		OnClearFilter()
		SortGames()
		PopulateSlots()
		if not bInstalling then
			T_RECENTLY_LAUNCHED_GAME = atGame
			if atGame[E_GAME_KEYS.PROCESS_OVERRIDE] ~= nil then
				-- Monitor the process defined in the manual override
				C_PROCESS_MONITOR:Start(atGame[E_GAME_KEYS.PROCESS_OVERRIDE])
			elseif atGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.STEAM then
				-- Monitor the Steam Overlay process
				C_PROCESS_MONITOR:Start('GameOverlayUI.exe')
			elseif atGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.BATTLENET then
				-- Monitor the default game process
				C_PROCESS_MONITOR:Start(atGame[E_GAME_KEYS.PROCESS])
			else
				-- Monitor the executable that the shortcut points to
				local sProcessPath = string.gsub(string.gsub(sPath, "\\", "/"), "//", "/")
				local sProcessName = sProcessPath:reverse()
				sProcessName = sProcessName:match("(exe%p[^\\/:%*?<>|]+)/")
				if sProcessName ~= nil then
					sProcessName = sProcessName:reverse()
					C_PROCESS_MONITOR:Start(sProcessName)
				end
			end
			if atGame[E_GAME_KEYS.IGNORES_BANGS] ~= true then
				ExecuteStartingBangs()
			end
		end
		local tArguments = atGame[E_GAME_KEYS.ARGUMENTS]
		if tArguments ~= nil then
			sArguments = table.concat(tArguments, '" "')
			SKIN:Bang('["' .. sPath .. '" "' .. sArguments .. '"]')
		else
			SKIN:Bang('["' .. sPath .. '"]')
		end
		return true
	end
--###########################################################################################################
--                          -> Hiding games
--###########################################################################################################
	function HideGame(atGame, abSerializeAndUpdateSlots)
		abSerializeAndUpdateSlots = abSerializeAndUpdateSlots or false
		if atGame[E_GAME_KEYS.HIDDEN] then
			return false
		end
		atGame[E_GAME_KEYS.HIDDEN] = true

		function move_game_from_to(atGameToMove, atFrom, atTo)
			for i, tGame in ipairs(atFrom) do
				if tGame == atGameToMove then
					table.insert(atTo, table.remove(atFrom, i))
					return true
				end
			end
			return false
		end

		local bMoved = false
		if move_game_from_to(atGame, T_ALL_GAMES, T_HIDDEN_GAMES) then
			bMoved = true
		elseif move_game_from_to(atGame, T_NOT_INSTALLED_GAMES, T_HIDDEN_GAMES) then
			bMoved = true
		end
		if abSerializeAndUpdateSlots and bMoved then
			C_RESOURCES:WriteGames()
			for i, tGame in ipairs(T_FILTERED_GAMES) do
				if tGame == atGame then
					table.remove(T_FILTERED_GAMES, i)
					local scrollIndex = N_SCROLL_INDEX
					SortGames()
					N_SCROLL_INDEX = scrollIndex
					PopulateSlots()
					break
				end
			end
		end
		return bMoved
	end
--###########################################################################################################
--                          -> Unhiding games
--###########################################################################################################
	function UnhideGame(atGame, abSerializeAndUpdateSlots)
		abSerializeAndUpdateSlots = abSerializeAndUpdateSlots or false
		if not atGame[E_GAME_KEYS.HIDDEN] then
			return false
		end
		atGame[E_GAME_KEYS.HIDDEN] = nil

		function move_game_from_to(atGameToMove, atFrom, atTo)
			for i, tGame in ipairs(atFrom) do
				if tGame == atGameToMove then
					table.insert(atTo, table.remove(atFrom, i))
					return true
				end
			end
			return false
		end

		local bMoved = false
		if atGame[E_GAME_KEYS.NOT_INSTALLED] then
			bMoved = move_game_from_to(atGame, T_HIDDEN_GAMES, T_NOT_INSTALLED_GAMES)
		else
			bMoved = move_game_from_to(atGame, T_HIDDEN_GAMES, T_ALL_GAMES)
		end
		if abSerializeAndUpdateSlots and bMoved then
			C_RESOURCES:WriteGames()
			for i, tGame in ipairs(T_FILTERED_GAMES) do
				if tGame == atGame then
					table.remove(T_FILTERED_GAMES, i)
					break
				end
			end
			if #T_FILTERED_GAMES > 0 then
				local scrollIndex = N_SCROLL_INDEX
				SortGames()
				N_SCROLL_INDEX = scrollIndex
				PopulateSlots()
			else
				OnToggleUnhideGames()
				OnClearFilter()
			end
		end
		return bMoved
	end
--###########################################################################################################
--                          -> Installing games
--###########################################################################################################
	function InstallGame(atGame)
		atGame[E_GAME_KEYS.NOT_INSTALLED] = nil
		for i, tNotInstalledGame in ipairs(T_NOT_INSTALLED_GAMES) do
			if tNotInstalledGame == atGame then
				table.insert(T_ALL_GAMES, table.remove(T_NOT_INSTALLED_GAMES, i))
				return true
			end
		end
		return false
	end
--###########################################################################################################
--                          -> Bangs
--###########################################################################################################
	function ExecuteStartingBangs()
		print("Executing starting bangs")
		if T_SETTINGS[E_SETTING_KEYS.BANGS_STARTING] ~= nil
		   and T_SETTINGS[E_SETTING_KEYS.BANGS_STARTING] ~= '' then
			SKIN:Bang((T_SETTINGS[E_SETTING_KEYS.BANGS_STARTING]:gsub('`', '"')))
		end
	end

	function ExecuteStoppingBangs()
		print("Executing stopping bangs")
		if T_RECENTLY_LAUNCHED_GAME[E_GAME_KEYS.IGNORES_BANGS] ~= true
		   and T_SETTINGS[E_SETTING_KEYS.BANGS_STOPPING] ~= nil
		   and T_SETTINGS[E_SETTING_KEYS.BANGS_STOPPING] ~= '' then
		    -- The extra set of parentheses are used to just use the first return value of gsub
			SKIN:Bang((T_SETTINGS[E_SETTING_KEYS.BANGS_STOPPING]:gsub('`', '"')))
		end
	end
--###########################################################################################################
--                          -> Filtering
--###########################################################################################################
	function FilterBy(asPattern)
		if asPattern == '' then
			T_FILTERED_GAMES = ClearFilter(T_ALL_GAMES)
			SortGames()
			PopulateSlots()
			return
		end
		local sort = true
		asPattern = asPattern:lower()
		if STRING:StartsWith(asPattern, '+') then
			T_FILTERED_GAMES, sort = Filter(T_FILTERED_GAMES, asPattern:sub(2))
		else
			local tTableOfGames = {}
			for i, tGame in ipairs(T_ALL_GAMES) do
				table.insert(tTableOfGames, tGame)
			end
			if T_SETTINGS[E_SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
				for i, tGame in ipairs(T_HIDDEN_GAMES) do
					if tGame[E_GAME_KEYS.NOT_INSTALLED] ~= true then
						table.insert(tTableOfGames, tGame)
					end
				end
			end
			T_FILTERED_GAMES, sort = Filter(tTableOfGames, asPattern)
			print(#T_FILTERED_GAMES)
			for i, tGame in ipairs(T_FILTERED_GAMES) do
				print(tGame[E_GAME_KEYS.NAME])
			end
		end
		if sort then
			SortGames()
		else
			N_SCROLL_INDEX = 1
		end
		PopulateSlots()
	end

	function FilterPlatform(atTable, asPattern, asTag, anPlatform)
		local tResult = {}
		asPattern = asPattern:sub(#asTag + 1)
		if STRING:StartsWith(asPattern, 'i') then --platform:installed
			for i, tGame in ipairs(atTable) do
				if tGame[E_GAME_KEYS.PLATFORM] == anPlatform and tGame[E_GAME_KEYS.NOT_INSTALLED] ~= true then
					table.insert(tResult, tGame)
				end
			end
		elseif STRING:StartsWith(asPattern, 'u') then --platform:uninstalled
			for i, tGame in ipairs(atTable) do
				if tGame[E_GAME_KEYS.PLATFORM] == anPlatform and tGame[E_GAME_KEYS.NOT_INSTALLED] == true then
					table.insert(tResult, tGame)
				end
			end
		elseif STRING:StartsWith(asPattern, 'a') then --platform:all
			for i, tGame in ipairs(atTable) do
				if tGame[E_GAME_KEYS.PLATFORM] == anPlatform then
					table.insert(tResult, tGame)
				end
			end
		elseif STRING:StartsWith(asPattern, 'p') then --platform:played
			for i, tGame in ipairs(atTable) do
				if tGame[E_GAME_KEYS.PLATFORM] == anPlatform and tGame[E_GAME_KEYS.HOURS_TOTAL] > 0 then
					table.insert(tResult, tGame)
				end
			end
		elseif STRING:StartsWith(asPattern, 'n') then --platform:not played
			for i, tGame in ipairs(atTable) do
				if tGame[E_GAME_KEYS.PLATFORM] == anPlatform and tGame[E_GAME_KEYS.HOURS_TOTAL] <= 0 then
					table.insert(tResult, tGame)
				end
			end
		elseif STRING:StartsWith(asPattern, 'f') then --platform:false
			for i, tGame in ipairs(atTable) do
				if tGame[E_GAME_KEYS.PLATFORM] ~= anPlatform then
					table.insert(tResult, tGame)
				end
			end
		end
		return tResult
	end

	function Filter(atTable, asPattern)
		local tResult = {}
		if atTable == nil then
			return tResult, false
		end
		if STRING:StartsWith(asPattern, 'steam:') then
			tResult = FilterPlatform(atTable, asPattern, 'steam:', E_PLATFORMS.STEAM)
		elseif STRING:StartsWith(asPattern, 'galaxy:') then
			tResult = FilterPlatform(atTable, asPattern, 'galaxy:', E_PLATFORMS.GOG_GALAXY)
		elseif STRING:StartsWith(asPattern, 'battlenet:') then
			tResult = FilterPlatform(atTable, asPattern, 'battlenet:', E_PLATFORMS.BATTLENET)
		elseif STRING:StartsWith(asPattern, 'tags:') then
			asPattern = asPattern:sub(6)
			for i, tGame in ipairs(atTable) do
				if tGame[E_GAME_KEYS.TAGS] ~= nil then
					for sKey, sValue in pairs(tGame[E_GAME_KEYS.TAGS]) do
						if sValue:lower():find(asPattern) then
							table.insert(tResult, tGame)
							break
						end
					end
				end
			end
		elseif STRING:StartsWith(asPattern, 'installed:') then
			asPattern = asPattern:sub(11)
			if STRING:StartsWith(asPattern, 't') then
				for i, tGame in ipairs(atTable) do
					if tGame[E_GAME_KEYS.NOT_INSTALLED] ~= true then
						table.insert(tResult, tGame)
					end
				end				
			elseif STRING:StartsWith(asPattern, 'f') then
				for i, tGame in ipairs(atTable) do
					if tGame[E_GAME_KEYS.NOT_INSTALLED] == true then
						table.insert(tResult, tGame)
					end
				end
			end
		elseif STRING:StartsWith(asPattern, 'hidden:') then
			asPattern = asPattern:sub(8)
			if STRING:StartsWith(asPattern, 't') then
				for i, tGame in ipairs(atTable) do
					table.insert(tResult, tGame)
				end
			elseif STRING:StartsWith(asPattern, 'f') then
				for i, tGame in ipairs(atTable) do
					if tGame[E_GAME_KEYS.HIDDEN] ~= true then
						table.insert(tResult, tGame)
					end
				end
			end
		elseif STRING:StartsWith(asPattern, 'games:') then
			asPattern = asPattern:sub(7)
			if STRING:StartsWith(asPattern, 'a') then
				for i, tGame in ipairs(T_ALL_GAMES) do
					table.insert(tResult, tGame)
				end
				for i, tGame in ipairs(T_NOT_INSTALLED_GAMES) do
					table.insert(tResult, tGame)
				end
				for i, tGame in ipairs(T_HIDDEN_GAMES) do
					table.insert(tResult, tGame)
				end
			end	
		elseif STRING:StartsWith(asPattern, 'random:') then
			asPattern = asPattern:sub(8)
			if asPattern == '' then
				table.insert(tResult, atTable[math.random(1, #atTable)])
			else
				function get_all_games()
					local tAllGames = {}
					for i, tGame in ipairs(T_ALL_GAMES) do
						table.insert(tAllGames, tGame)
					end
					for i, tGame in ipairs(T_NOT_INSTALLED_GAMES) do
						table.insert(tAllGames, tGame)
					end
					if T_SETTINGS[E_SETTING_KEYS.SHOW_HIDDEN_GAMES] == true then
						for i, tGame in ipairs(T_HIDDEN_GAMES) do
							table.insert(tAllGames, tGame)
						end
					end
					print(#tAllGames)
					return tAllGames
				end

				if STRING:StartsWith(asPattern, 'a') then
					tResult = get_all_games()
					if tResult ~= nil and #tResult > 0 then
						tResult = {tResult[math.random(1, #tResult)]}
					end
				else
					function get_all_games_from_platform(anPlatform)
						local tAllGames = get_all_games()
						local i = 1
						while i <= #tAllGames do
							if tAllGames[i][E_GAME_KEYS.PLATFORM] ~= anPlatform then
								table.remove(tAllGames, i)
							else
								i = i + 1
							end
						end
						return tAllGames
					end

					if STRING:StartsWith(asPattern, 's') then
						tResult = get_all_games_from_platform(E_PLATFORMS.STEAM)
					elseif STRING:StartsWith(asPattern, 'g') then
						tResult = get_all_games_from_platform(E_PLATFORMS.GOG_GALAXY)
					elseif STRING:StartsWith(asPattern, 'b') then
						tResult = get_all_games_from_platform(E_PLATFORMS.BATTLENET)
					elseif STRING:StartsWith(asPattern, 'p') then
						tResult = get_all_games()
						local i = 1
						while i <= #tResult do
							if tAllGames[i][E_GAME_KEYS.HOURS_TOTAL] <= 0 then
								table.remove(tResult, i)
							else
								i = i + 1
							end
						end
					elseif STRING:StartsWith(asPattern, 'n') then
						tResult = get_all_games()
						local i = 1
						while i <= #tResult do
							if tAllGames[i][E_GAME_KEYS.HOURS_TOTAL] > 0 then
								table.remove(tResult, i)
							else
								i = i + 1
							end
						end
					end
					if tResult ~= nil and #tResult > 0 then
						tResult = {tResult[math.random(1, #tResult)]}
					end
				end
			end
		elseif STRING:StartsWith(asPattern, 'played:') then
			asPattern = asPattern:sub(8)
			if STRING:StartsWith(asPattern, 't') then
				for i, tGame in ipairs(atTable) do
					if tGame[E_GAME_KEYS.HOURS_TOTAL] > 0 then
						table.insert(tResult, tGame)
					end
				end
			elseif STRING:StartsWith(asPattern, 'f') then	
				for i, tGame in ipairs(atTable) do
					if tGame[E_GAME_KEYS.HOURS_TOTAL] <= 0 then
						table.insert(tResult, tGame)
					end
				end
			end
		elseif STRING:StartsWith(asPattern, 'shortcuts:') then
			asPattern = asPattern:sub(11)
			for i, tGame in ipairs(atTable) do
				if tGame[E_GAME_KEYS.PLATFORM_OVERRIDE] ~= nil
				   and tGame[E_GAME_KEYS.PLATFORM_OVERRIDE]:lower():find(asPattern) then
					table.insert(tResult, tGame)
				end
			end
		else
			if T_SETTINGS[E_SETTING_KEYS.FUZZY_SEARCH] == true then
				local tRankings = {}
				for i, tGame in ipairs(atTable) do
					nScore = FuzzySearch(asPattern, tGame[E_GAME_KEYS.NAME])
					if nScore > 0 then
						table.insert(tRankings, {score = nScore, game = tGame})
					end
				end
				table.sort(tRankings, SortRanking)
				--print("== " .. asPattern .. " ==") -- Debug
				for i, entry in ipairs(tRankings) do
					--print(entry.score, entry.game[E_GAME_KEYS.NAME]) -- Debug
					table.insert(tResult, entry.game)
				end
				print(#tResult)
				return tResult, false
			else
				for i, tGame in ipairs(atTable) do
					if tGame[E_GAME_KEYS.NAME]:lower():find(asPattern) then
						table.insert(tResult, tGame)
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
			if atTable[i][E_GAME_KEYS.HIDDEN] ~= true and atTable[i][E_GAME_KEYS.NOT_INSTALLED] ~= true  then
				table.insert(tResult, atTable[i])
			end
		end
		return tResult
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
--###########################################################################################################
--                          -> Sorting
--###########################################################################################################
	function SortGames()
		if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES <= 0 then
			return
		end
		if T_SETTINGS[E_SETTING_KEYS.SORT_STATE] == E_SORTING_STATES.ALPHABETICALLY then
			table.sort(T_FILTERED_GAMES, SortAlphabetically)
		elseif T_SETTINGS[E_SETTING_KEYS.SORT_STATE] == E_SORTING_STATES.LAST_PLAYED then
			table.sort(T_FILTERED_GAMES, SortLastPlayed)
		elseif T_SETTINGS[E_SETTING_KEYS.SORT_STATE] == E_SORTING_STATES.HOURS_PLAYED then
			table.sort(T_FILTERED_GAMES, SortHoursPlayed)
		end
		N_SCROLL_INDEX = 1
	end

	function SortAlphabetically(atFirst, atSecond)
		if atFirst[E_GAME_KEYS.NAME]:lower():gsub(':', ' ')
		   < atSecond[E_GAME_KEYS.NAME]:lower():gsub(':', ' ') then
			return true
		else
			return false
		end
	end

	function SortLastPlayed(atFirst, atSecond)
		local nFirst = tonumber(atFirst[E_GAME_KEYS.LASTPLAYED])
		local nSecond = tonumber(atSecond[E_GAME_KEYS.LASTPLAYED])
		if nFirst > nSecond then
			return true
		elseif nFirst == nSecond then
			return SortAlphabetically(atFirst, atSecond)
		else
			return false
		end
	end

	function SortHoursPlayed(atFirst, atSecond)
		local nFirst = tonumber(atFirst[E_GAME_KEYS.HOURS_TOTAL])
		local nSecond = tonumber(atSecond[E_GAME_KEYS.HOURS_TOTAL])
		if nFirst > nSecond then
			return true
		elseif nFirst == nSecond then
			return SortAlphabetically(atFirst, atSecond)
		else
			return false
		end
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
--###########################################################################################################
--         -> Animations
--###########################################################################################################
--###########################################################################################################
-- End of refactoring
--###########################################################################################################
--[[
-- OLD VERSION
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
	   or T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 0 or B_ANIMATING then
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
	if T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'vertical' then
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 1 then
			SetSlotsXPosition(T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH] * nFactor)
		elseif T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 2 then
			SetSlotsXPosition(T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH] * nFactor * -1)
		end
	else --horizontal
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 3 then
			SetSlotsYPosition(T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT] * nFactor)
		elseif T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] == 4 then
			SetSlotsYPosition(T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT] * nFactor * -1)
		end
	end
	SKIN:Bang('[!Redraw]')
end

function SetSlotsXPosition(anValue)
	for i = 1, tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT]) do
		SKIN:Bang(
			'[!SetOption "SlotText' .. i .. '" "X" "' .. anValue
			+ T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH] / 2 .. '"]'
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
	for i = 1, tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT]) do
		SKIN:Bang(
			'[!SetOption "SlotText' .. i .. '" "Y" "' .. anValue
			+ T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT] / 2 .. '"]'
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

	function Unhighlight(asIndex)
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			SKIN:Bang('[!HideMeterGroup "SlotHighlight' .. asIndex .. '"]')
		end
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] > 0 then
			if T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'vertical' then
				SKIN:Bang(
					'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
					.. '[!UpdateMeasure "HoverOffAnimation"]'
					.. '[!CommandMeasure "HoverOffAnimation" "Execute 1"]'
				)
			elseif T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'horizontal' then
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
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			SKIN:Bang('[!ShowMeterGroup "SlotHighlight' .. asIndex ..'"]')
		end
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] > 0 and not B_ANIMATING and B_SKIN_VISIBLE then
			if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] == 1 then
				if T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'vertical' then
					SKIN:Bang(
						'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
						.. '[!UpdateMeasure "HoverOnAnimation"]'
						.. '[!CommandMeasure "HoverOnAnimation" "Execute 1"]'
					)
				elseif T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'horizontal' then
					SKIN:Bang(
						'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
						.. '[!UpdateMeasure "HoverOnAnimation"]'
						.. '[!CommandMeasure "HoverOnAnimation" "Execute 2"]'
					)
				end
			elseif T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] == 2 then
				SKIN:Bang(
					'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
					.. '[!UpdateMeasure "HoverOnAnimation"]'
					.. '[!CommandMeasure "HoverOnAnimation" "Execute 3"]'
				)
			elseif T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] == 3 then
				SKIN:Bang(
					'[!SetVariable "SlotToAnimate" "' .. asIndex .. '"]'
					.. '[!UpdateMeasure "HoverOnAnimation"]'
					.. '[!CommandMeasure "HoverOnAnimation" "Execute 4"]'
				)
			end
		end
	end
--]]