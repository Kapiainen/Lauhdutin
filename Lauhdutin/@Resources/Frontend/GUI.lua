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
	--     f = function
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
--                  -> Initialized
--###########################################################################################################
	function OnInitialized()
	-- Called by the Python backend script when it has finished
	-- Show games or display a message that there are no games to show
		C_STATUS_MESSAGE:Hide()
		T_ALL_GAMES = C_RESOURCES:ReadGames()
		for sKey, tTable in pairs(T_ALL_GAMES) do
			if tTable[E_GAME_KEYS.HIDDEN] == true then
				table.insert(T_HIDDEN_GAMES, tTable)
			elseif tTable[E_GAME_KEYS.NOT_INSTALLED] == true then
				table.insert(T_NOT_INSTALLED_GAMES, tTable)
			else
				table.insert(T_GAMES, tTable)
			end
		end
		if T_GAMES ~= nil and #T_GAMES > 0 then
			FilterBy('')
		elseif T_NOT_INSTALLED_GAMES ~= nil and #T_NOT_INSTALLED_GAMES > 0 then
			FilterBy('installed:false')
		elseif T_HIDDEN_GAMES ~= nil and #T_HIDDEN_GAMES > 0 then
			FilterBy('hidden:true')
		else
			C_STATUS_MESSAGE:Show('No games to display')
		end
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] > 0 then
			C_SCRIPT:SetUpdateDivider(1)
			OnMouseLeaveSkin()
		end
	end
--###########################################################################################################
--                  -> Status update
--###########################################################################################################
	function OnShowStatus(asMessage)
		C_STATUS_MESSAGE:Show(asMessage)
	end
--###########################################################################################################
--                  -> Skin
--###########################################################################################################
	function OnMouseEnterSkin(abAnimate)
	-- Called when the mouse cursor enters the skin
	-- abAnimate: Whether or not to play an animation to unhide the skin
		if abAnimate then
			if C_SKIN.bVisible then
				return
			end
			C_SCRIPT:SetUpdateDivider(1)
			PopulateSlots()
			C_ANIMATIONS:PushSkinSlideIn()
		else
			C_SCRIPT:SetUpdateDivider(1)
		end
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM_RUNNING] then
			SKIN:Bang(
				'[!SetOption "SteamMonitor" "UpdateDivider" "63"]'
				.. '[!UpdateMeasure "SteamMonitor"]'
				.. '[!SetOption "BattlenetMonitor" "UpdateDivider" "63"]'
				.. '[!UpdateMeasure "BattlenetMonitor"]'
			)
		end
	end

	function OnMouseLeaveSkin()
	-- Called when the mouse cursor leaves the skin
	-- abAnimate: Whether or not to play an animation to hide the skin
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			C_SLOT_HIGHLIGHT:Hide(false)
		end
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] > 0 then
			C_ANIMATIONS:PushHoverReset(C_SKIN.nMouseIndex)
		end
		C_TOOLBAR:Hide()
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION] > 0 then
			if not C_TOOLBAR.bForciblyVisible then
				C_ANIMATIONS:PushSkinSlideOut()
			end
		else
			C_SCRIPT:SetUpdateDivider(-1)
			Redraw()
		end
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM_RUNNING] then
			SKIN:Bang(
				'[!SetOption "SteamMonitor" "UpdateDivider" "-1"]'
				.. '[!UpdateMeasure "SteamMonitor"]'
				.. '[!SetOption "BattlenetMonitor" "UpdateDivider" "-1"]'
				.. '[!UpdateMeasure "BattlenetMonitor"]'
			)
		end
	end

	function OnScrollSlots(anDirection)
	-- Called when the list of games is scrolled
	-- anDirection: Positive value -> Upwards, Negative value -> Downwards
		local nSlotCount = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT])
		local nScrollIndex = N_SCROLL_INDEX
		local nScrollStep = 1
		if T_SETTINGS[E_SETTING_KEYS.SLOT_ROWS_COLUMNS] > 1 then
			nScrollStep = T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT_PER_ROW_COLUMN]
		end
		if #T_FILTERED_GAMES > nSlotCount then
			if anDirection > 0 then
				if nScrollIndex == 1 then
					return
				end
				nScrollIndex = nScrollIndex - nScrollStep
				if nScrollIndex < 1 then
					nScrollIndex = 1
				end
			elseif anDirection < 0 then
				local nUpperLimit = #T_FILTERED_GAMES + 1 - nSlotCount
				if nScrollIndex == nUpperLimit then
					return
				end
				nScrollIndex = nScrollIndex + nScrollStep
				if nScrollIndex > nUpperLimit then
					nScrollIndex = nUpperLimit
				end
			end
		end
		N_SCROLL_INDEX = nScrollIndex
	end

	function OnSkinOutOfView()
		UnloadSlots()
	end
--###########################################################################################################
--                  -> Toolbar
--###########################################################################################################
	function OnMouseEnterToolbar(abForce)
		abForce = abForce or false
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			C_SLOT_HIGHLIGHT:Hide()
		end
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] > 0 then
			C_ANIMATIONS:ResetSlotAnimation({nSlotIndex = C_SKIN.nMouseIndex})
		end
		C_TOOLBAR:Show(abForce)
	end

	function OnMouseLeaveToolbar(abForce)
		abForce = abForce or false
		C_TOOLBAR:Hide(abForce)
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			C_SLOT_HIGHLIGHT:MoveTo(C_SKIN.nMouseIndex)
			if C_SLOT_HIGHLIGHT:Update(C_SKIN.nMouseIndex) then
				if not C_TOOLBAR.bForciblyVisible then
					C_SLOT_HIGHLIGHT:Show()
				end
			end
		end
		local nAnimation = T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER]
		if nAnimation > 0 and not C_TOOLBAR.bVisible then
			if N_ACTION_STATE == E_ACTION_STATES.EXECUTE
			   or N_ACTION_STATE == E_ACTION_STATES.HIDE
			   or N_ACTION_STATE == E_ACTION_STATES.UNHIDE then
				C_ANIMATIONS:PushHover(nAnimation, C_SKIN.nMouseIndex)
			end
		end
	end

	function OnStartInputtingFilter()
		OnMouseEnterToolbar(true)
		if T_SETTINGS[E_SETTING_KEYS.ADJUST_ZPOS] then
			if C_SKIN:UpdateDefaultZPos() then
				C_SKIN:SetZPos(0)
			end
		end
		SKIN:Bang('[!CommandMeasure "FilterInput" "ExecuteBatch 1"]')
	end

	function OnDismissFilterInput()
		if T_SETTINGS[E_SETTING_KEYS.ADJUST_ZPOS] then
			C_SKIN:ResetZPos()
		end
		C_TOOLBAR.bForciblyVisible = false
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			if C_SLOT_HIGHLIGHT:Update(C_SKIN.nMouseIndex) then
				if not C_TOOLBAR.bVisible then
					C_SLOT_HIGHLIGHT:Show()
				end
			end
		end
	end

	function OnFinishedInputtingFilter(asPattern)
		if T_SETTINGS[E_SETTING_KEYS.ADJUST_ZPOS] then
			C_SKIN:ResetZPos()
		end
		OnApplyFilter(asPattern)
	end

	function OnApplyFilter(asPattern)
		C_STATUS_MESSAGE:Hide()
		if asPattern == '' then
			FilterBy('')
		else
			FilterBy(asPattern)
		end
		C_TOOLBAR:Hide(true)
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			if C_SLOT_HIGHLIGHT:Update(C_SKIN.nMouseIndex) then
				if not C_TOOLBAR.bVisible then
					C_SLOT_HIGHLIGHT:Show()
				end
			end
		end
		if #T_FILTERED_GAMES <= 0 then
			OnShowStatus('No matches')
		end
	end

	function OnClearFilter()
		OnApplyFilter('')
	end

	function OnCycleSorting()
		T_SETTINGS[E_SETTING_KEYS.SORT_STATE] = T_SETTINGS[E_SETTING_KEYS.SORT_STATE] + 1
		if T_SETTINGS[E_SETTING_KEYS.SORT_STATE] > 2 then
			T_SETTINGS[E_SETTING_KEYS.SORT_STATE] = 0
		end
		C_TOOLBAR.bReversedSorting = false
		C_TOOLBAR:UpdateSortingIcon()
		C_RESOURCES:WriteSettings()
		SortGames()
		PopulateSlots()
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			C_SLOT_HIGHLIGHT:Update(C_SKIN.nMouseIndex)
		end
		Redraw()
	end

	function OnReverseSorting()
		C_TOOLBAR:ToggleReverseSorting()
		C_TOOLBAR:UpdateSortingIcon()
		local tReversed = {}
		for i, tGame in ipairs(T_FILTERED_GAMES) do
			table.insert(tReversed, 1, tGame)
		end
		T_FILTERED_GAMES = tReversed
		PopulateSlots()
		if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
			C_SLOT_HIGHLIGHT:Update(C_SKIN.nMouseIndex)
		end
		Redraw()
	end
--###########################################################################################################
--                  -> Slot
--###########################################################################################################
	function OnMouseEnterSlot(anIndex)
	-- Called when the mouse cursor enters a slot
	-- anIndex: The index of the slot in question (1-indexed)
		C_SKIN.nMouseIndex = anIndex
		if not C_TOOLBAR.bVisible then
			if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
				C_SLOT_HIGHLIGHT:MoveTo(C_SKIN.nMouseIndex)
				if C_SLOT_HIGHLIGHT:Update(C_SKIN.nMouseIndex) then
					C_SLOT_HIGHLIGHT:Show(true)
				end
			end
			local nAnimation = T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER]
			if nAnimation > 0 then
				if N_ACTION_STATE == E_ACTION_STATES.EXECUTE
				   or N_ACTION_STATE == E_ACTION_STATES.HIDE
				   or N_ACTION_STATE == E_ACTION_STATES.UNHIDE then
					C_ANIMATIONS:PushHover(nAnimation, anIndex)
				end
			end
		end
	end

	function OnMouseLeaveSlot(anIndex)
	-- Called when the mouse cursor leaves a slot
	-- anIndex: The index of the slot in question (1-indexed)
		--SLOT:Unhighlight(anIndex)
		if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] > 0 then
			C_ANIMATIONS:PushHoverReset(anIndex)
		end
	end

	function OnLeftClickSlot(anIndex)
	-- Called when a slot is left-mouse clicked
	-- anIndex: The index of the slot in question (1-indexed)
		if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES <= 0 then
			return
		end
		local tGame = T_FILTERED_GAMES[N_SCROLL_INDEX + anIndex - 1]
		if tGame == nil then
			return
		end
		local nAnimation = T_SETTINGS[E_SETTING_KEYS.ANIMATION_CLICK]
		if nAnimation > 0 then
			if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] > 0 then
				C_ANIMATIONS:PushHoverReset(anIndex)
			end
			if N_ACTION_STATE == E_ACTION_STATES.EXECUTE then
				C_ANIMATIONS:PushClick(nAnimation, anIndex, LaunchGame, tGame)
			elseif N_ACTION_STATE == E_ACTION_STATES.HIDE then
				C_ANIMATIONS:PushClick(nAnimation, anIndex, HideGame, tGame)
			elseif N_ACTION_STATE == E_ACTION_STATES.UNHIDE then
				C_ANIMATIONS:PushClick(nAnimation, anIndex, UnhideGame, tGame)
			end
		else
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
	end

	function OnMiddleClickSlot(anIndex)
	-- Called when a slot is middle-mouse clicked
	-- anIndex: The index of the slot in question (1-indexed)
		if C_SLOT_SUBMENU:MoveTo(anIndex) then
			C_SLOT_SUBMENU:Show(true)
		end
	end
--###########################################################################################################
--                  -> Slot submenu
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
		C_SLOT_SUBMENU:ToggleVisibility()
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
		OnApplyFilter('installed:false')
	end

	function OnShowHidden()
		OnApplyFilter('hidden:true')
	end
--###########################################################################################################
--                  -> Process monitoring
--###########################################################################################################
	function OnProcessTerminated()
		if not C_PROCESS_MONITOR then
			return
		end
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

	function OnSteamProcessStarted()
		if not C_SKIN then
			return
		end
		C_SKIN.bSteamRunning = true
	end

	function OnSteamProcessTerminated()
		if not C_SKIN then
			return
		end
		C_SKIN.bSteamRunning = false
	end

	function OnBattlenetProcessStarted()
		if not C_SKIN then
			return
		end
		C_SKIN.bBattlenetRunning = true
	end

	function OnBattlenetProcessTerminated()
		if not C_SKIN then
			return
		end
		C_SKIN.bBattlenetRunning = false
	end
--###########################################################################################################
-- Private
--###########################################################################################################
--         -> State update and rendering
--###########################################################################################################
	function Update()
	-- Called regularly (every ~16 ms) by Rainmeter when the mouse is on the skin
		if not C_ANIMATIONS then
			return
		end
		if C_ANIMATIONS:Pending() then
		-- If there are animations to play, then play a frame and redraw
			C_ANIMATIONS:Play()
		elseif N_LAST_DRAWN_SCROLL_INDEX ~= N_SCROLL_INDEX then
		-- If scroll index has changed, then redraw
			if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
				C_SLOT_HIGHLIGHT:Update(C_SKIN.nMouseIndex)
			end
			C_SLOT_SUBMENU:Hide(false)
			if PopulateSlots() then
				if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] > 0 then
					C_ANIMATIONS:UpdateHoverAnimation(C_SKIN.nMouseIndex)
				end
				N_LAST_DRAWN_SCROLL_INDEX = N_SCROLL_INDEX
			end
		end
	end

	function Redraw()
		--print("Redraw")
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

	function UnloadSlots()
		if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES <= 0 then
			return
		end
		local nSlotCount = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT])
		for i = 1, nSlotCount do
			SKIN:Bang(
				'[!SetOption "SlotBanner' .. i .. '" "ImageName" ""]'
			)
		end
		SKIN:Bang('[!UpdateMeterGroup Slots]')
	end
--###########################################################################################################
--         -> Initialization
--###########################################################################################################
	function Initialize()
	-- Called when the skin is loaded
		local sResourcesPath = SKIN:GetVariable('@')
		JSON = dofile(sResourcesPath .. 'Dependencies\\json4lua\\json.lua')
		STRING = dofile(sResourcesPath .. 'Frontend\\String.lua')
		InitializeEnums(sResourcesPath)
		InitializeStateVariables()
		InitializeConstants()
		if not InitializeComponents(sResourcesPath) then
			SKIN:Bang('[!ActivateConfig "#CURRENTCONFIG#" "Settings.ini"]')
			return
		end
		C_TOOLBAR:Hide()
		C_SLOT_HIGHLIGHT:Hide()
		C_SLOT_SUBMENU:Hide()
		C_TOOLBAR:UpdateSortingIcon()
		if tonumber(T_SETTINGS[E_SETTING_KEYS.TOOLBAR_POSITION]) == 1 then
			C_TOOLBAR:MoveToBottom()
		end
		C_STATUS_MESSAGE:Show('Initializing...')
		SKIN:Bang('["#Python#" "#@#Backend\\GetGames.py" "#PROGRAMPATH#;" "#@#;" "#CURRENTCONFIG#;"]')
	end
--###########################################################################################################
--                           -> Components
--###########################################################################################################
	function InitializeComponents(asResourcesPath)
		C_SKIN = InitializeSkin()
		C_SCRIPT = InitializeScript()
		C_RESOURCES = InitializeResources(asResourcesPath)
		T_SETTINGS = C_RESOURCES:ReadSettings()
		if not T_SETTINGS then
			return false
		end
		C_TOOLBAR = InitializeToolbar()
		C_STATUS_MESSAGE = InitializeStatusMessage()
		C_SLOT_SUBMENU = InitializeSlotSubmenu()
		C_PROCESS_MONITOR = InitializeProcessMonitor()
		C_SLOT_HIGHLIGHT = InitializeSlotHighlight()
		C_ANIMATIONS = InitializeAnimations()
		return true
	end
--###########################################################################################################
--                                         -> Skin
--###########################################################################################################
	function InitializeSkin()
		return {
			bVisible = true,
			nDefaultZPos = nil,
			sSettingsPath = SKIN:GetVariable('SETTINGSPATH', nil),
			sConfig = SKIN:GetVariable('CURRENTCONFIG', nil),
			bSkinAnimationPlaying = false,
			bSteamRunning = false,
			bBattlenetRunning = false,
			nMouseIndex = -1,

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
--###########################################################################################################
--                                         -> Script
--###########################################################################################################
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
--###########################################################################################################
--                                         -> Resources
--###########################################################################################################
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

			WriteGames = function (self)
				return self:WriteJSON('games.json', T_ALL_GAMES)
			end
		}
	end
--###########################################################################################################
--                                         -> Toolbar
--###########################################################################################################
	function InitializeToolbar()
		return {
			bVisible = true,
			bForciblyVisible = false,
			bTopPosition = true,
			bReversedSorting = false,

			Show = function (self, abForce)
			-- 
			-- abForce: 
				abForce = abForce or false
				-- If skin not visible, then return
				if bVisible then
					return
				end
				self.bVisible = true
				if abForce then
					self.bForciblyVisible = true
				end
				-- If reverse sort, then show appropriate icon
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
				if not self.bVisible then
					return
				end
				self.bVisible = false
				SKIN:Bang('[!HideMeterGroup Toolbar]')
				Redraw()
			end,

			UpdateSortingIcon = function (self, abRedraw)
				abRedraw = abRedraw or false
				if self.bReversedSorting then
					SKIN:Bang(
						'[!SetOption "ToolbarButtonSort" "ImageName" "#@#Icons\\Sort'
						.. T_SETTINGS[E_SETTING_KEYS.SORT_STATE] .. 'R.png"]'
						.. '[!UpdateMeter "ToolbarButtonSort"]'
					)
				else
					SKIN:Bang(
						'[!SetOption "ToolbarButtonSort" "ImageName" "#@#Icons\\Sort'
						.. T_SETTINGS[E_SETTING_KEYS.SORT_STATE] .. '.png"]'
						.. '[!UpdateMeter "ToolbarButtonSort"]'
					)
				end
				if abRedraw then
					Redraw()
				end
			end,

			ToggleReverseSorting = function (self)
				self.bReversedSorting = not self.bReversedSorting
			end,

			SetScoreSortingIcon = function (self)
				SKIN:Bang(
					'[!SetOption "ToolbarButtonSort" "ImageName" "#@#Icons\\SortScore.png"]'
					.. '[!UpdateMeter "ToolbarButtonSort"]'
				)
			end,

			MoveToBottom = function (self)
				self.bTopPosition = false
				SKIN:Bang(
					'[!SetOption "ToolbarEnabler" "Y" "(#SkinMaxHeight# - 1)"]'
					.. '[!UpdateMeter "ToolbarEnabler"]'
					.. '[!SetOption "ToolbarBackground" "Y" "(#SkinMaxHeight# - 50)"]'
					.. '[!SetOption "ToolbarButtonSearch" "Y" "(#SkinMaxHeight# - 49)"]'
					.. '[!SetOption "ToolbarSeparator1" "Y" "(#SkinMaxHeight# - 45)"]'
					.. '[!SetOption "ToolbarButtonSort" "Y" "(#SkinMaxHeight# - 49)"]'
					.. '[!SetOption "ToolbarSeparator2" "Y" "(#SkinMaxHeight# - 45)"]'
					.. '[!SetOption "ToolbarButtonSettings" "Y" "(#SkinMaxHeight# - 49)"]'
					.. '[!UpdateMeterGroup "Toolbar"]'
					.. '[!SetOption "FilterInput" "Y" "(#SkinMaxHeight# - 90)"]'
					.. '[!UpdateMeasure "FilterInput"]'
				)
			end
		}
	end
--###########################################################################################################
--                                         -> Status message
--###########################################################################################################
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
				)
				Redraw()
			end,

			Hide = function (self)
			--
			-- asMessage: 
				if not self.bVisible then
					return
				end
				SKIN:Bang(
					'[!HideMeterGroup "Status"]'
				)
				Redraw()
			end
		}
	end
--###########################################################################################################
--                                         -> Slot submenu
--###########################################################################################################
	function InitializeSlotSubmenu()
		return {
			nCurrentIndex = 0,
			bVisible = false,

			MoveTo = function (self, anIndex)
				self.nCurrentIndex = anIndex or 1
				local tGame = self:GetGame()
				if tGame == nil then
					return false
				end
				local mBanner = SKIN:GetMeter('SlotBanner' .. anIndex)
				local nSlotWidth = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH])
				local nX = mBanner:GetX(true)
				local nSlotHeight = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT])
				local nY = mBanner:GetY(true)
				SKIN:Bang(
					'[!SetOption "SlotSubmenuBackground" "X" "' .. nX + (nSlotWidth - nSlotWidth / 1.1) / 2 .. '"]'
					.. '[!SetOption "SlotSubmenuBackground" "Y"' .. nY + (nSlotHeight - nSlotHeight / 1.1) / 2 .. '"]'
					.. '[!SetOption "SlotSubmenuIcon1" "X" "(' .. nX .. ' + #SlotWidth# / 6 - 15)"]'
				)
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
					'[!UpdateMeterGroup "SlotSubmenu"]'
				)
				return true
			end,

			Show = function (self, abRedraw)
				abRedraw = abRedraw or false
				self.bVisible = true
				SKIN:Bang('[!ShowMeterGroup "SlotSubmenu"]')
				if abRedraw then
					Redraw()
				end
			end,

			Hide = function (self, abRedraw)
				abRedraw = abRedraw or false
				self.bVisible = false
				SKIN:Bang('[!HideMeterGroup "SlotSubmenu"]')
				if abRedraw then
					Redraw()
				end
			end,

			StartEditingNotes = function (self)
				local tGame = self:GetGame()
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
					for i, tGame in ipairs(T_ALL_GAMES) do
						if tGame[E_GAME_KEYS.NAME] == tEditedGame[E_GAME_KEYS.NAME]
						   and tGame[E_GAME_KEYS.PLATFORM] == tEditedGame[E_GAME_KEYS.PLATFORM]  then
							tGame[E_GAME_KEYS.NOTES] = tEditedGame[E_GAME_KEYS.NOTES]
							C_RESOURCES:WriteGames()
							return true
						end
					end
				end
				return false
			end,

			StartEditingTags = function (self)
				local tGame = self:GetGame()
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
					for i, tGame in ipairs(T_ALL_GAMES) do
						if tGame[E_GAME_KEYS.NAME] == tEditedGame[E_GAME_KEYS.NAME] then
							tGame[E_GAME_KEYS.TAGS] = tEditedGame[E_GAME_KEYS.TAGS]
							C_RESOURCES:WriteGames()
							return true
						end
					end
				end
				return false
			end,

			ToggleBangs = function (self)
				local tGame = self:GetGame()
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
				local tGame = self:GetGame()
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
				local tGame = self:GetGame()
				if tGame == nil then
					return
				end
				--Toggle flag and move to the appropriate table
				if tGame[E_GAME_KEYS.HIDDEN] == true then --Unhide game
					
					tGame[E_GAME_KEYS.HIDDEN] = false
					if not MoveGameFromTo(tGame, T_HIDDEN_GAMES, T_GAMES) then
						MoveGameFromTo(tGame, T_HIDDEN_GAMES, T_NOT_INSTALLED_GAMES)
					end
				else --Hide game
					tGame[E_GAME_KEYS.HIDDEN] = true
					if not MoveGameFromTo(tGame, T_GAMES, T_HIDDEN_GAMES) then
						MoveGameFromTo(tGame, T_NOT_INSTALLED_GAMES, T_HIDDEN_GAMES)
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
				if #T_FILTERED_GAMES > 0 then
					if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] > 0 then
						C_ANIMATIONS:ResetSlotAnimation({nSlotIndex = self.nCurrentIndex})
						PopulateSlots()
						C_ANIMATIONS:PushHover(
							T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER],
							C_SKIN.nMouseIndex
						)
					else
						PopulateSlots()
					end
					if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT] then
						C_SLOT_HIGHLIGHT:Update(C_SKIN.nMouseIndex)
					end
				else
					if T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER] > 0 then
						C_ANIMATIONS:ResetSlotAnimation({nSlotIndex = self.nCurrentIndex})
						OnApplyFilter('')
						C_ANIMATIONS:PushHover(
							T_SETTINGS[E_SETTING_KEYS.ANIMATION_HOVER],
							C_SKIN.nMouseIndex
						)
					else
						OnApplyFilter('')
					end
				end
				self:Hide(true)
			end,

			GetGame = function (self)
				if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES == 0 then
					return nil
				end
				return T_FILTERED_GAMES[N_SCROLL_INDEX + self.nCurrentIndex - 1]
			end
		}
	end
--###########################################################################################################
--                                         -> Process monitor
--###########################################################################################################
	function InitializeProcessMonitor()
		return {
			sMeasureName = 'ProcessMonitor',

			Start = function (self, asProcessName)
				SKIN:Bang(
					'[!SetOption "' .. self.sMeasureName .. '" "UpdateDivider" "63"]'
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
--###########################################################################################################
--                                         -> Slot highlight
--###########################################################################################################
	function InitializeSlotHighlight()
		return {
			bVisible = true,

			MoveTo = function (self, anIndex)
				local mSlot = SKIN:GetMeter('SlotBanner' .. anIndex)
				if mSlot == nil then
					return
				end
				SKIN:Bang(
					'[!SetOption "SlotHighlightBackground" "X" "' .. mSlot:GetX(true) .. '"]'
					.. '[!SetOption "SlotHighlightBackground" "Y" "' .. mSlot:GetY(true) .. '"]'
					.. '[!UpdateMeterGroup "SlotHighlight"]'
				)
			end,

			Update = function (self, anIndex)
				if T_FILTERED_GAMES == nil or #T_FILTERED_GAMES <= 0 then
					self:Hide()
					return false
				end
				local tGame = T_FILTERED_GAMES[N_SCROLL_INDEX + anIndex - 1]
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
					elseif T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM_RUNNING]
					   and (tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.STEAM
					   		or tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.STEAM_SHORTCUT)
					   and not C_SKIN.bSteamRunning then
						SKIN:Bang(
							'[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightError.png"]'
						)
						sHighlightMessage = T_PLATFORM_DESCRIPTIONS[tGame[E_GAME_KEYS.PLATFORM] + 1]
											.. ' is not running'
					elseif T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM_RUNNING]
						   and tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.BATTLENET
						   and not C_SKIN.bBattlenetRunning then
						SKIN:Bang(
							'[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightError.png"]'
						)
						sHighlightMessage = T_PLATFORM_DESCRIPTIONS[tGame[E_GAME_KEYS.PLATFORM] + 1]
											.. ' is not running'
					elseif tGame[E_GAME_KEYS.NOT_INSTALLED] then
						if tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.STEAM
						   or tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.BATTLENET then
							SKIN:Bang(
								'[!SetOption "SlotHighlight" "ImageName" '
								.. '"#@#Icons\\SlotHighlightInstall.png"]'
							)
							if tGame[E_GAME_KEYS.PLATFORM_OVERRIDE] then
								sHighlightMessage = tGame[E_GAME_KEYS.PLATFORM_OVERRIDE]
													.. ' - Install'
							else
								sHighlightMessage = T_PLATFORM_DESCRIPTIONS[tGame[E_GAME_KEYS.PLATFORM] + 1]
													.. ' - Install'
							end
						else
							SKIN:Bang(
								'[!SetOption "SlotHighlight" "ImageName" '
								.. '"#@#Icons\\SlotHighlightNotInstalled.png"]'
							)
							if tGame[E_GAME_KEYS.PLATFORM_OVERRIDE] then
								sHighlightMessage = tGame[E_GAME_KEYS.PLATFORM_OVERRIDE]
													.. ' - Not installed'
							else
								sHighlightMessage = T_PLATFORM_DESCRIPTIONS[tGame[E_GAME_KEYS.PLATFORM] + 1]
													.. ' - Not installed'
							end
						end
					else
						SKIN:Bang(
							'[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightPlay.png"]'
						)
						if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT_PLATFORM] then
							if tGame[E_GAME_KEYS.PLATFORM_OVERRIDE] then
								sHighlightMessage = tGame[E_GAME_KEYS.PLATFORM_OVERRIDE]
							else
								sHighlightMessage = T_PLATFORM_DESCRIPTIONS[tGame[E_GAME_KEYS.PLATFORM] + 1]
							end
						end
					end
				elseif N_ACTION_STATE == E_ACTION_STATES.HIDE then
					SKIN:Bang('[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightHide.png"]')
					if tGame[E_GAME_KEYS.HIDDEN] then
						sHighlightMessage = 'Already hidden'
					else
						sHighlightMessage = 'Hide'
					end
				elseif N_ACTION_STATE == E_ACTION_STATES.UNHIDE then
					SKIN:Bang('[!SetOption "SlotHighlight" "ImageName" "#@#Icons\\SlotHighlightUnhide.png"]')
					if tGame[E_GAME_KEYS.HIDDEN] then
						sHighlightMessage = 'Unhide'
					else
						sHighlightMessage = 'Already unhidden'
					end
				end
				if N_ACTION_STATE == E_ACTION_STATES.EXECUTE then
					sHighlightMessage = sHighlightMessage .. '#CRLF##CRLF##CRLF##CRLF##CRLF#'
					if T_SETTINGS[E_SETTING_KEYS.SLOT_HIGHLIGHT_HOURS_PLAYED] then
						local nHoursPlayed = math.floor(tGame[E_GAME_KEYS.HOURS_TOTAL])
						if nHoursPlayed == 1 then
							sHighlightMessage = sHighlightMessage .. '1 hour'
						else
							sHighlightMessage = sHighlightMessage .. nHoursPlayed .. ' hours'
						end
					end
				end
				SKIN:Bang('[!SetOption "SlotHighlightText" "Text" "' .. sHighlightMessage .. '"]')
				SKIN:Bang('[!UpdateMeterGroup "SlotHighlight"]')
				return true
			end,

			Show = function (self, abRedraw)
				abRedraw = abRedraw or false
				if self.bVisible then
					return
				end
				self.bVisible = true
				SKIN:Bang('[!ShowMeterGroup "SlotHighlight"]')
				if abRedraw then
					Redraw()
				end
			end,

			Hide = function (self, abRedraw)
				abRedraw = abRedraw or false
				if not self.bVisible then
					return
				end
				self.bVisible = false
				SKIN:Bang('[!HideMeterGroup "SlotHighlight"]')
				if abRedraw then
					Redraw()
				end
			end
		}
	end
--###########################################################################################################
--                           -> Enums
--###########################################################################################################
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
--###########################################################################################################
--                           -> State variables
--###########################################################################################################
	function InitializeStateVariables()
		T_SLOT_ANIMATION_QUEUE = {}
		N_ACTION_STATE = 0
		N_LAST_DRAWN_SCROLL_INDEX = 1
		N_SCROLL_INDEX = 1
		T_GAMES = {}
		T_FILTERED_GAMES = {}
		T_HIDDEN_GAMES = {}
		T_NOT_INSTALLED_GAMES = {}
		T_RECENTLY_LAUNCHED_GAME = nil
	end
--###########################################################################################################
--                           -> Constants
--###########################################################################################################
	function InitializeConstants()
		T_PLATFORM_DESCRIPTIONS = {
			"Steam",
			"Steam",
			"GOG Galaxy",
			"Shortcut",
			"Shortcut",
			"Blizzard App"
		}
	end
--###########################################################################################################
--         -> Functionality
--###########################################################################################################
--                          -> Launching games
--###########################################################################################################
	function LaunchGame(atGame)
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
			if atGame[E_GAME_KEYS.IGNORES_BANGS] ~= true then
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
	function HideGame(atGame)
		if atGame[E_GAME_KEYS.HIDDEN] then
			return false
		end
		atGame[E_GAME_KEYS.HIDDEN] = true
		local bMoved = false
		if MoveGameFromTo(atGame, T_GAMES, T_HIDDEN_GAMES) then
			bMoved = true
		elseif MoveGameFromTo(atGame, T_NOT_INSTALLED_GAMES, T_HIDDEN_GAMES) then
			bMoved = true
		end
		if bMoved then
			C_RESOURCES:WriteGames()
			for i, tGame in ipairs(T_FILTERED_GAMES) do
				if tGame == atGame then
					table.remove(T_FILTERED_GAMES, i)
					break
				end
			end
			if #T_FILTERED_GAMES > 0 then
				local nScrollIndex = N_SCROLL_INDEX
				SortGames()
				local nSlotCount = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT])
				if #T_FILTERED_GAMES <= nSlotCount then
					nScrollIndex = 1
				elseif nScrollIndex > #T_FILTERED_GAMES + 1 - nSlotCount then -- TODO: replace '1' with nScrollStep
					nScrollIndex = nScrollIndex - 1
				end
				N_SCROLL_INDEX = nScrollIndex
				PopulateSlots()
			else
				OnToggleHideGames()
				OnClearFilter()
			end
		end
		return bMoved
	end
--###########################################################################################################
--                          -> Unhiding games
--###########################################################################################################
	function UnhideGame(atGame)
		if not atGame[E_GAME_KEYS.HIDDEN] then
			return false
		end
		atGame[E_GAME_KEYS.HIDDEN] = nil
		local bMoved = false
		if atGame[E_GAME_KEYS.NOT_INSTALLED] then
			bMoved = MoveGameFromTo(atGame, T_HIDDEN_GAMES, T_NOT_INSTALLED_GAMES)
		else
			bMoved = MoveGameFromTo(atGame, T_HIDDEN_GAMES, T_GAMES)
		end
		if bMoved then
			C_RESOURCES:WriteGames()
			for i, tGame in ipairs(T_FILTERED_GAMES) do
				if tGame == atGame then
					table.remove(T_FILTERED_GAMES, i)
					break
				end
			end
			if #T_FILTERED_GAMES > 0 then
				local nScrollIndex = N_SCROLL_INDEX
				SortGames()
				local nSlotCount = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT])
				if #T_FILTERED_GAMES <= nSlotCount then
					nScrollIndex = 1
				elseif nScrollIndex > #T_FILTERED_GAMES + 1 - nSlotCount then -- TODO: replace '1' with nScrollStep
					nScrollIndex = nScrollIndex - 1
				end
				N_SCROLL_INDEX = nScrollIndex
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
				table.insert(T_GAMES, table.remove(T_NOT_INSTALLED_GAMES, i))
				return true
			end
		end
		return false
	end
--###########################################################################################################
--                          -> Bangs
--###########################################################################################################
	function ExecuteStartingBangs()
		if T_SETTINGS[E_SETTING_KEYS.BANGS_STARTING] ~= nil
		   and T_SETTINGS[E_SETTING_KEYS.BANGS_STARTING] ~= '' then
			SKIN:Bang((T_SETTINGS[E_SETTING_KEYS.BANGS_STARTING]:gsub('`', '"')))
		end
	end

	function ExecuteStoppingBangs()
		if T_RECENTLY_LAUNCHED_GAME[E_GAME_KEYS.IGNORES_BANGS] ~= true
		   and T_SETTINGS[E_SETTING_KEYS.BANGS_STOPPING] ~= nil
		   and T_SETTINGS[E_SETTING_KEYS.BANGS_STOPPING] ~= '' then
			SKIN:Bang((T_SETTINGS[E_SETTING_KEYS.BANGS_STOPPING]:gsub('`', '"')))
		end
	end
--###########################################################################################################
--                          -> Filtering
--###########################################################################################################
	function FilterBy(asPattern)
		if asPattern == '' then
			T_FILTERED_GAMES = ClearFilter(T_GAMES)
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
				if (tGame[E_GAME_KEYS.HIDDEN] and T_SETTINGS[E_SETTING_KEYS.SHOW_HIDDEN_GAMES])
				   or (tGame[E_GAME_KEYS.NOT_INSTALLED]
				   	  and T_SETTINGS[E_SETTING_KEYS.SHOW_NOT_INSTALLED_GAMES])
				   or (not tGame[E_GAME_KEYS.HIDDEN] and not tGame[E_GAME_KEYS.NOT_INSTALLED]) then
					table.insert(tTableOfGames, tGame)
				end
			end
			T_FILTERED_GAMES, sort = Filter(tTableOfGames, asPattern)
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
		elseif STRING:StartsWith(asPattern, 't') then --platform:true
			for i, tGame in ipairs(atTable) do
				if tGame[E_GAME_KEYS.PLATFORM] == anPlatform then
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
		elseif STRING:StartsWith(asPattern, 'blizzard:') then
			tResult = FilterPlatform(atTable, asPattern, 'blizzard:', E_PLATFORMS.BATTLENET)
		elseif STRING:StartsWith(asPattern, 'battlenet:') then --Deprecate at some point
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
				for i, tGame in ipairs(T_ALL_GAMES) do
					if tGame[E_GAME_KEYS.NOT_INSTALLED] ~= true then
						table.insert(tResult, tGame)
					end
				end				
			elseif STRING:StartsWith(asPattern, 'f') then
				for i, tGame in ipairs(T_ALL_GAMES) do
					if tGame[E_GAME_KEYS.NOT_INSTALLED] == true then
						table.insert(tResult, tGame)
					end
				end
			end
		elseif STRING:StartsWith(asPattern, 'hidden:') then
			asPattern = asPattern:sub(8)
			if STRING:StartsWith(asPattern, 't') then
				for i, tGame in ipairs(T_ALL_GAMES) do
					if tGame[E_GAME_KEYS.HIDDEN] == true then
						table.insert(tResult, tGame)
					end
				end
			elseif STRING:StartsWith(asPattern, 'f') then
				for i, tGame in ipairs(T_ALL_GAMES) do
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
					return tAllGames
				end

				if STRING:StartsWith(asPattern, 'a') then
					tResult = get_all_games()
					if tResult ~= nil and #tResult > 0 then
						tResult = {tResult[math.random(1, #tResult)]}
					end
				else
					function get_all_games()
						local tAllGames = {}
						for i, tGame in ipairs(T_ALL_GAMES) do
							if (tGame[E_GAME_KEYS.HIDDEN] and T_SETTINGS[E_SETTING_KEYS.SHOW_HIDDEN_GAMES])
							   or (tGame[E_GAME_KEYS.NOT_INSTALLED]
							   	  and T_SETTINGS[E_SETTING_KEYS.SHOW_NOT_INSTALLED_GAMES])
							   or (not tGame[E_GAME_KEYS.HIDDEN] and not tGame[E_GAME_KEYS.NOT_INSTALLED]) then
								table.insert(tAllGames, tGame)
							end
						end
						return tAllGames
					end
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
			if asPattern == '' then
				for i, tGame in ipairs(atTable) do
					if tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.WINDOWS_SHORTCUT
					   or tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.WINDOWS_URL_SHORTCUT then
						table.insert(tResult, tGame)
					end
				end
			else
				for i, tGame in ipairs(atTable) do
					if tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.WINDOWS_SHORTCUT
					   or tGame[E_GAME_KEYS.PLATFORM] == E_PLATFORMS.WINDOWS_URL_SHORTCUT then
						if tGame[E_GAME_KEYS.PLATFORM_OVERRIDE] ~= nil
						   and tGame[E_GAME_KEYS.PLATFORM_OVERRIDE]:lower():find(asPattern) then
							table.insert(tResult, tGame)
						end
					end
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
				C_TOOLBAR:SetScoreSortingIcon()
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
		C_TOOLBAR.bReversedSorting = false
		C_TOOLBAR:UpdateSortingIcon()
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
--                          -> Misc
--###########################################################################################################
	function MoveGameFromTo(atGame, atFrom, atTo)
		for i = 1, #atFrom do
			if atFrom[i] == atGame then
				table.insert(atTo, table.remove(atFrom, i))
				return true
			end
		end
		return false
	end
--###########################################################################################################
--         -> Animations
--###########################################################################################################
	function InitializeAnimations()
		return {
			tQueue = {},
			bPlaying = false,
			nSlotX = 0,
			nSlotY = 0,

			Pending = function (self)
				return #self.tQueue > 0
			end,

			Play = function (self)
				if self.bPlaying then
					return false
				end
				self.bPlaying = true
				if #self.tQueue <= 0 then
					self.bPlaying = false
					return false
				end
				local tAnimationSet = nil
				local bCancel = false
				if #self.tQueue > 1 then
					if self.tQueue[1].tArguments.bMandatory then
						if self.tQueue[1].tArguments.nFrames == 0 then
							tAnimationSet = table.remove(self.tQueue, 1)
						else
							tAnimationSet = self.tQueue[1]
						end
					else
						bCancel = true
						tAnimationSet = table.remove(self.tQueue, 1)
						tAnimationSet.tArguments.nFrames = 0
						while #self.tQueue > 1 and not self.tQueue[1].tArguments.bMandatory do
							table.remove(self.tQueue, 1)
						end
					end
				elseif self.tQueue[1].tArguments.nFrames == 0 then
					tAnimationSet = table.remove(self.tQueue, 1)
				else
					tAnimationSet = self.tQueue[1]
				end
				if tAnimationSet == nil then
					self.bPlaying = false
					return false
				end
				if bCancel then
					if tAnimationSet.tArguments.fReset then
						tAnimationSet.tArguments.fReset(self, tAnimationSet.tArguments)
					end
				elseif tAnimationSet.fFunction ~= nil then
					tAnimationSet.fFunction(self, tAnimationSet.tArguments)
					tAnimationSet.tArguments.nFrames = tAnimationSet.tArguments.nFrames - 1
				end
				self.bPlaying = false
				return true
			end,

			Push = function (self, atAnimationSet)
				table.insert(self.tQueue, atAnimationSet)
			end,

			PrepareSlotAnimation = function (self, atArguments)
				if atArguments.nSlotIndex < 1 then
					return
				end
				local mBanner = SKIN:GetMeter('SlotBanner' .. atArguments.nSlotIndex)
				local sBannerPath = mBanner:GetOption('ImageName')
				if not sBannerPath or sBannerPath == '' then
					return
				end
				local nX = mBanner:GetX(true)
				self.nSlotX = nX
				local nY = mBanner:GetY(true)
				self.nSlotY = nY
				local nW = mBanner:GetW()
				local nH = mBanner:GetH()
				SKIN:Bang(
					'[!SetOption "SlotAnimation" "W" "' .. nW ..'"]'
					.. '[!SetOption "SlotAnimation" "H" "' .. nH .. '"]'
					.. '[!SetOption "SlotAnimation" "X" "' .. nX .. '"]'
					.. '[!SetOption "SlotAnimation" "Y" "' .. nY .. '"]'
					.. '[!SetOption "SlotAnimation" "ImageName" "' .. sBannerPath .. '"]'
					.. '[!SetOption "CutoutBackground" "Shape2" '
					.. '"Rectangle ' .. nX .. ',' .. nY .. ',' .. nW .. ',' .. nH .. '"]'
					.. '[!SetOption "SlotBanner' .. atArguments.nSlotIndex .. '" "ImageAlpha" "0"]'
					.. '[!UpdateMeter "SlotAnimation"]'
					.. '[!UpdateMeter "CutoutBackground"]'
					.. '[!UpdateMeter "SlotBanner' .. atArguments.nSlotIndex .. '"]'
				)
			end,

			ResetSlotAnimation = function (self, atArguments)
				if atArguments.nSlotIndex < 1 then
					return
				end
				SKIN:Bang(
					'[!SetOption "SlotAnimation" "W" "0"]'
					.. '[!SetOption "SlotAnimation" "H" "0"]'
					.. '[!SetOption "SlotAnimation" "X" "-1"]'
					.. '[!SetOption "SlotAnimation" "Y" "-1"]'
					.. '[!SetOption "SlotAnimation" "ImageName" ""]'
					.. '[!SetOption "CutoutBackground" "Shape2" "Rectangle 0,0,0,0"]'
					.. '[!SetOption "SlotBanner' .. atArguments.nSlotIndex .. '" "ImageAlpha" "255"]'
					.. '[!UpdateMeter "SlotBanner' .. atArguments.nSlotIndex .. '"]'
					.. '[!UpdateMeter "SlotAnimation"]'
					.. '[!UpdateMeter "CutoutBackground"]'
				)
			end,

			-- Animation functions
			--   Click
			PushClick = function (self, anType, anSlotIndex, afAction, atGame)
				if anType < 1 or anSlotIndex < 1 or anSlotIndex > T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT]
				   or afAction == nil or atGame == nil then
					return
				end
				local tAnimationSets = {
					{ -- Shrink
						fFunction = self.ClickShrink,
						tArguments = {
							nFrames = 3,
							nSlotIndex = anSlotIndex,
							bHorizontal = false,
							fPrepare = self.PrepareSlotAnimation,
							fReset = self.ClickReset
						}
					},
					{ -- Shift left
						fFunction = self.ClickShift,
						tArguments = {
							nFrames = 4,
							nSlotIndex = anSlotIndex,
							nDirection = 1,
							bHorizontal = false,
							fPrepare = self.PrepareSlotAnimation,
							fReset = self.ClickReset
						}
					},
					{ -- Shift right
						fFunction = self.ClickShift,
						tArguments = {
							nFrames = 4,
							nSlotIndex = anSlotIndex,
							nDirection = -1,
							bHorizontal = false,
							fPrepare = self.PrepareSlotAnimation,
							fReset = self.ClickReset
						}
					},
					{ -- Shift up
						fFunction = self.ClickShift,
						tArguments = {
							nFrames = 4,
							nSlotIndex = anSlotIndex,
							nDirection = 1,
							bHorizontal = true,
							fPrepare = self.PrepareSlotAnimation,
							fReset = self.ClickReset
						}
					},
					{ -- Shift left
						fFunction = self.ClickShift,
						tArguments = {
							nFrames = 4,
							nSlotIndex = anSlotIndex,
							nDirection = -1,
							bHorizontal = true,
							fPrepare = self.PrepareSlotAnimation,
							fReset = self.ClickReset
						}
					}
				}
				local tAnimationSet = tAnimationSets[anType]
				if not tAnimationSet then
					return
				end
				tAnimationSet.tArguments.fAction = afAction
				tAnimationSet.tArguments.tGame = atGame
				self:Push(tAnimationSet)
			end,
			--     Shrink
			ClickShrink = function (self, atArguments)
				local nFrame = 3 - atArguments.nFrames + 1
				local nSizeFactor = 1.0
				if nFrame == 1 then
					atArguments.fPrepare(self, atArguments)
					nSizeFactor = 1.0 / 1.8
				elseif nFrame == 2 then
					nSizeFactor = 1.0 / 4.0
				elseif nFrame == 3 then
					nSizeFactor = 1.0 / 20.0
				else
					atArguments.fReset(self, atArguments)
					return
				end
				local nSlotWidth = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH])
				local nSlotHeight = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT])
				local nWidth = nSlotWidth * nSizeFactor
				local nHeight = nSlotHeight * nSizeFactor
				local nX = (nSlotWidth - nWidth) / 2 + self.nSlotX
				local nY = (nSlotHeight - nHeight) / 2 + self.nSlotY
				SKIN:Bang(
					'[!SetOption "SlotAnimation" "X" "' .. nX .. '"]'
					.. '[!SetOption "SlotAnimation" "Y" "' .. nY .. '"]'
					.. '[!SetOption "SlotAnimation" "W" "' .. nWidth .. '"]'
					.. '[!SetOption "SlotAnimation" "H" "' .. nHeight .. '"]'
					.. '[!UpdateMeter "SlotAnimation"]'
				)
			end,
			--     Shift
			ClickShift = function (self, atArguments)
				local nFrame = 4 - atArguments.nFrames + 1
				local nNewPosition = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH])
				if nFrame == 1 then
					atArguments.fPrepare(self, atArguments)
					nNewPosition = 0 - nNewPosition / 20.0
				elseif nFrame == 2 then
					nNewPosition = 0 - nNewPosition / 4.0
				elseif nFrame == 3 then
					nNewPosition = 0 - nNewPosition / 1.8
				elseif nFrame == 4 then
					nNewPosition = 0 - nNewPosition
				else
					atArguments.fReset(self, atArguments)
					return
				end
				local sOption = 'X'
				if atArguments.bHorizontal then
					sOption = 'Y'
					nNewPosition = nNewPosition * atArguments.nDirection + self.nSlotY
				else
					nNewPosition = nNewPosition * atArguments.nDirection + self.nSlotX
				end
				
				SKIN:Bang(
					'[!SetOption "SlotAnimation" "' .. sOption .. '" "'
					.. nNewPosition .. '"]'
					.. '[!UpdateMeter "SlotAnimation"]'
				)
			end,

			ClickReset = function (self, atArguments)
				atArguments.fAction(atArguments.tGame)
				self:ResetSlotAnimation(atArguments)
			end,
			--   Hover
			PushHover = function (self, anType, anSlotIndex)
				if anType < 1
				   or anSlotIndex < 1
				   or anSlotIndex > tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT]) then
					return
				end
				local tAnimationSets = {
					{ -- Zoom in
						fFunction = self.HoverZoomIn,
						tArguments = {
							nFrames = 3,
							nSlotIndex = anSlotIndex,
							bHorizontal = T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'horizontal',
							fPrepare = self.PrepareSlotAnimation,
							fReset = self.ResetSlotAnimation
						}
					},
					{ -- Jiggle
						fFunction = self.HoverJiggle,
						tArguments = {
							nFrames = 4,
							nSlotIndex = anSlotIndex,
							bHorizontal = T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'horizontal',
							fPrepare = self.PrepareSlotAnimation,
							fReset = self.ResetSlotAnimation
						}
					},
					{ -- Shake
						fFunction = self.HoverShake,
						tArguments = {
							nFrames = 4,
							nSlotIndex = anSlotIndex,
							bHorizontal = T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'horizontal',
							fPrepare = self.PrepareSlotAnimation,
							fReset = self.ResetSlotAnimation
						}
					}
				}
				local tAnimationSet = tAnimationSets[anType]
				if not tAnimationSet then
					return
				end
				self:Push(tAnimationSet)
			end,
			--     Zoom in
			HoverZoomIn = function (self, atArguments)
				local nFrame = 3 - atArguments.nFrames + 1
				local nSlotIndex = atArguments.nSlotIndex
				local nSizeFactor = 1.0
				if nFrame == 1 then
					atArguments.fPrepare(self, atArguments)
					nSizeFactor = 1.05
				elseif nFrame == 2 then
					nSizeFactor = 1.10
				elseif nFrame == 3 then
					nSizeFactor = 1.15
				else
					return
				end
				local nSlotHeight = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT])
				local nY = self.nSlotY -((nSizeFactor * nSlotHeight) - nSlotHeight) / 2
				local nH = nSizeFactor * nSlotHeight
				local nSlotWidth = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH])
				local nX = self.nSlotX - ((nSizeFactor * nSlotWidth) - nSlotWidth) / 2
				local nW = nSizeFactor * nSlotWidth
				SKIN:Bang(
					'[!SetOption "SlotAnimation" "X" "' .. nX .. '"]'
					.. '[!SetOption "SlotAnimation" "W" "' .. nW .. '"]'
					.. '[!SetOption "SlotAnimation" "Y" "' .. nY .. '"]'
					.. '[!SetOption "SlotAnimation" "H" "' .. nH .. '"]'
					.. '[!UpdateMeter "SlotAnimation"]'
				)
			end,
			--     Jiggle
			HoverJiggle = function (self, atArguments)
				local nFrame = 4 - atArguments.nFrames + 1
				local nSlotIndex = atArguments.nSlotIndex
				local nSizeFactor = 1.0
				if nFrame == 1 then
					atArguments.fPrepare(self, atArguments)
					SKIN:Bang('[!SetOption "SlotAnimation" "ImageRotate" "2"]')
				elseif nFrame == 2 then
					SKIN:Bang('[!SetOption "SlotAnimation" "ImageRotate" "0"]')
				elseif nFrame == 3 then
					SKIN:Bang('[!SetOption "SlotAnimation" "ImageRotate" "-2"]')
				elseif nFrame == 4 then
					SKIN:Bang('[!SetOption "SlotAnimation" "ImageRotate" "0"]')
				else
					atArguments.fReset(self, atArguments)
					return
				end
				SKIN:Bang('[!UpdateMeter "SlotAnimation"]')
			end,
			--     Shake
			HoverShake = function (self, atArguments)
				local nFrame = 4 - atArguments.nFrames + 1
				local nSlotIndex = atArguments.nSlotIndex
				local sPositionOption = 'X'
				local nPositionValue = self.nSlotX
				if atArguments.bHorizontal then
					sPositionOption = 'Y'
					nPositionValue = self.nSlotY
				end
				if nFrame == 1 then
					atArguments.fPrepare(self, atArguments)
					nPositionValue = nPositionValue - 5
					SKIN:Bang(
						'[!SetOption "SlotAnimation" "'.. sPositionOption .. ' '
						.. '"' .. nPositionValue .. '"]'
					)
				elseif nFrame == 2 then
					SKIN:Bang(
						'[!SetOption "SlotAnimation" "'.. sPositionOption .. ' '
						.. '"' .. nPositionValue .. '"]'
					)
				elseif nFrame == 3 then
					nPositionValue = nPositionValue + 5
					SKIN:Bang(
						'[!SetOption "SlotAnimation" "'.. sPositionOption .. ' '
						.. '"' .. nPositionValue .. '"]'
					)
				elseif nFrame == 4 then
					SKIN:Bang(
						'[!SetOption "SlotAnimation" "'.. sPositionOption .. ' '
						.. '"' .. nPositionValue .. '"]'
					)
				else
					atArguments.fReset(self, atArguments)
					return
				end
				SKIN:Bang('[!UpdateMeter "SlotAnimation"]')
			end,

			PushHoverReset = function (self, anSlotIndex)
				if anSlotIndex < 1 or anSlotIndex > tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_COUNT]) then
					return
				end
				self:Push(
					{
						fFunction = self.HoverReset,
						tArguments = {
							nFrames = 0,
							nSlotIndex = anSlotIndex,
							bHorizontal = T_SETTINGS[E_SETTING_KEYS.ORIENTATION] == 'horizontal',
							fReset = self.ResetSlotAnimation
						}
					}
				)
			end,

			UpdateHoverAnimation = function (self, anIndex)
				local mBanner = SKIN:GetMeter('SlotBanner' .. anIndex)
				local sBannerPath = mBanner:GetOption('ImageName')
				SKIN:Bang(
					'[!SetOption "SlotAnimation" "ImageName" "' .. sBannerPath .. '"]'
					.. '[!UpdateMeter "SlotAnimation"]'
				)
			end,
			-- Skin slide animation
			PushSkinSlideIn = function (self)
				if C_SKIN.bSkinAnimationPlaying or C_SKIN.bVisible then
					return
				end
				local nDir = tonumber(T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION]) % 2
				if nDir <= 0 then
					nDir = -1
				end
				self:Push(
					{
						fFunction = self.SkinSlide,
						tArguments = {
							nFrames = 4,
							bMandatory = true,
							nDirection = nDir,
							bIntoView = true,
							bHorizontal = tonumber(T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION]) > 2
						}
					}
				)
			end,

			PushSkinSlideOut = function (self)
				if C_SKIN.bSkinAnimationPlaying or not C_SKIN.bVisible then
					return
				end
				local nDir = tonumber(T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION]) % 2
				if nDir <= 0 then
					nDir = -1
				end
				self:Push(
					{
						fFunction = self.SkinSlide,
						tArguments = {
							nFrames = 4,
							bMandatory = true,
							nDirection = nDir,
							bIntoView = false,
							bHorizontal = tonumber(T_SETTINGS[E_SETTING_KEYS.ANIMATION_SKIN_SLIDE_DIRECTION]) > 2
						}
					}
				)
			end,

			SkinSlide = function (self, atArguments)
				local nFrame = 4 - atArguments.nFrames + 1
				local nNewPosition = 0
				if atArguments.bHorizontal then
					nNewPosition = 0 - tonumber(SKIN:GetVariable('SkinMaxHeight'))
				else
					nNewPosition = 0 - tonumber(SKIN:GetVariable('SkinMaxWidth'))
				end
				local nDivider = 1.0
				if atArguments.bIntoView then
					if nFrame == 1 then
						C_SKIN.bSkinAnimationPlaying = true
						C_SKIN.bVisible = true
						nDivider = 1.8
					elseif nFrame == 2 then
						nDivider = 4.0
					elseif nFrame == 3 then
						nDivider = 20.0
					elseif nFrame == 4 then
						nNewPosition = 0
					else
						C_SKIN.bSkinAnimationPlaying = false
						return
					end
				else
					if nFrame == 1 then
						C_SKIN.bSkinAnimationPlaying = true
						nDivider = 20.0
					elseif nFrame == 2 then
						nDivider = 4.0
					elseif nFrame == 3 then
						nDivider = 1.8
					elseif nFrame == 4 then
						nDivider = 0.9
					else
						C_SCRIPT:SetUpdateDivider(-1)
						C_SKIN.bVisible = false
						C_SKIN.bSkinAnimationPlaying = false
						OnSkinOutOfView()
						return
					end
				end
				nNewPosition = nNewPosition * atArguments.nDirection / nDivider
				local sPositionOption = 'X'
				local nTextOffset = 0
				if atArguments.bHorizontal then
					sPositionOption = 'Y'
					nTextOffset = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_HEIGHT]) / 2
				else
					nTextOffset = tonumber(T_SETTINGS[E_SETTING_KEYS.SLOT_WIDTH]) / 2
				end
				nTextOffset = nTextOffset * atArguments.nDirection / nDivider
				SKIN:Bang(
					'[!SetOption "SlotsBackground" "' .. sPositionOption .. '" "' .. nNewPosition .. '"]'
					.. '[!UpdateMeter "SlotsBackground"]'
					.. '[!SetOption "CutoutBackground" "' .. sPositionOption .. '" "' .. nNewPosition .. '"]'
					.. '[!UpdateMeter "CutoutBackground"]'
					.. '[!UpdateMeterGroup "Slots"]'
					.. '[!SetOption "StatusMessage" "' .. sPositionOption .. '" '
					.. '"' .. nTextOffset .. '"]'
					.. '[!UpdateMeterGroup "Status"]'
					.. '[!SetOption "SlotHighlightBackground" "' .. sPositionOption .. '" '
					.. '"' .. nNewPosition .. '"]'
					.. '[!UpdateMeterGroup "SlotHighlight"]'
					.. '[!SetOption "ToolbarEnabler" "' .. sPositionOption .. '" "' .. nNewPosition .. '"]'
				)
				if not C_TOOLBAR.bTopPosition then
					SKIN:Bang('[!SetOption "ToolbarEnabler" "Y" "(#SkinMaxHeight# - 1)"]')
				end
				SKIN:Bang('[!UpdateMeter "ToolbarEnabler"]')
			end
		}
	end