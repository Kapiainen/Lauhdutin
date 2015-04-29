function Initialize()
	-- Folder paths to resources
	S_PATH_DOWNLOADS = SKIN:MakePathAbsolute("DownloadFile\\")
	S_PATH_RESOURCES = SKIN:GetVariable('@')
	
	-- State variables
	N_SORT_STATE = 1 -- 0 = alphabetically, 1 = most recently played
	B_FORCE_SHOW_TOOLBAR = false
	B_SHOW_TOOLBAR = false
	B_SHOWING_MESSAGE = false -- True = a message is being displayed, so don't replace the current message with a new one.
	S_NAME_FILTER = ''
	S_TAGS_FILTER = ''
	N_SCROLL_START_INDEX = 1 -- Index to start from when populating the game meters with games.

	-- Keys of user settings.
	S_USER_SETTING_KEY_WIDTH = 'BannerWidth' -- Width of game banners in pixels.
	S_USER_SETTING_KEY_HEIGHT = 'BannerHeight' -- Height of game banners in pixels.
	S_USER_SETTING_KEY_SLOTS = 'SlotCount' -- Number of rows.
	S_USER_SETTING_KEY_ORIENTATION = 'Orientation' -- How to arrange the games (up to down or left to right).
	S_USER_SETTINGS_KEY_HIDE_MESSAGES = 'HideMessages'

	-- Names of various files and folders.
	S_INCLUDE_FILE_VARIABLES = 'Variables.inc' -- File containing various variables that are not meant to be set manually by the user.
	S_INCLUDE_FILE_METERS = 'Meters.inc' -- File containing game meters.
	S_INCLUDE_FILE_EXCEPTIONS = 'Exceptions.inc' -- File containing AppIDs of Steam games to not include in the list of games.
	S_INCLUDE_FILE_NON_STEAM_GAMES = 'Games.inc' -- File containing data about non-Steam games and applications to include in the list of games.
	S_INCLUDE_FILE_STEAM_SHORTCUTS = 'SteamShortcuts.inc' -- File containing last played timestamp of non-Steam games that have been added to the Steam library.
	S_BANNER_FOLDER_NAME = 'Banners' -- Name of the folder containing all of the banners.

	-- Steam
	S_STEAM_RUN_COMMAND = 'steam://rungameid/' -- Command for running games via Steam.
	S_PATH_STEAM = SKIN:GetVariable('SteamPath', nil)
	if S_PATH_STEAM ~= nil then
		if S_PATH_STEAM ~= '' and EndsWith(S_PATH_STEAM, '\\') == false then
			S_PATH_STEAM = S_PATH_STEAM .. '\\'
		end
		S_PATH_STEAM = Trim(S_PATH_STEAM)
	end
	S_PATH_STEAM_LIBRARIES = SKIN:GetVariable('SteamLibraryPaths', nil)
	S_STEAM_USER_DATA_ID = SKIN:GetVariable('UserDataID', nil)
	if S_STEAM_USER_DATA_ID ~= nil then
		S_STEAM_USER_DATA_ID = Trim(S_STEAM_USER_DATA_ID)
	end

	-- VDF (de)serializing
	S_VDF_SERIALIZING_INDENTATION = '' -- Used for proper indentation when writing files formatted according to VDF.

	-- Keys of values found in files formatted according to VDF.
	S_VDF_KEY_APPID = 'appid' -- Steam AppID corresponding to a certain game.
	S_VDF_KEY_LAST_PLAYED = 'LastPlayed' -- Unix timestamp of when the game was last launched.
	S_VDF_KEY_NAME = 'name' -- The name of the game.
	S_VDF_KEY_TAGS = 'tags' -- Tags, usually categories.
	S_VDF_KEY_PATH = 'path'
	S_VDF_KEY_HIDDEN = 'hidden'
	S_VDF_KEY_STEAM = 'Steam' -- Whether or not a game is via Steam.
	S_VDF_KEY_STEAM_SHORTCUT = 'SteamShortcut' -- Whether or not this is a non-Steam game that has been added to the Steam library.
	S_VDF_KEY_USER_LOCAL_CONFIG_STORE = 'UserLocalConfigStore'
	S_VDF_KEY_SOFTWARE = 'Software'
	S_VDF_KEY_VALVE = 'Valve'
	S_VDF_KEY_APPS = 'apps'
	S_VDF_KEY_APP_TICKETS = 'apptickets'
	S_VDF_KEY_APP_STATE = 'AppState'
	S_VDF_KEY_USER_CONFIG = 'UserConfig'

	-- Miscellaneous
	T_GAMES = {} -- List of all games.
	T_FILTERED_GAMES = {} -- List of games after they have been filtered according to user-defined criteria.
	T_LOGO_QUEUE = {} -- List of Steam AppIDs to download banners for.
	T_SETTINGS = {} -- User settings
	T_SUPPORTED_BANNER_EXTENSIONS = {'.jpg', '.png'} -- Extensions to use when checking if a banner already exists for a game or not.
	N_SCROLL_MULTIPLIER = tonumber(SKIN:GetVariable('ScrollMultiplier', '1'))
	S_BANNER_VARIABLE_PREFIX = 'BannerID' -- Stem of the name of variables, which contain the names of banner files used, used by the game meters.

end

function Update() -- Generates the list of games and, if necessary, the layout of game meters.
	T_SETTINGS = GetSettings(false)
	local OldSettings = GetSettings(true)
	if SettingsHaveChanged(T_SETTINGS, OldSettings) then
		StoreSettings(T_SETTINGS)
		GenerateMetersAndVariables()
		SKIN:Bang('!Refresh')
	else
		T_GAMES = GenerateGames()
		if #T_GAMES <= 0 then
			ShowToolbar()
			ForceShowToolbar(true)
			DisplayMessage('No games to show#CRLF#Check readme')
		else
			local ScrollStartIndexOld = N_SCROLL_START_INDEX
			if S_NAME_FILTER ~= '' then
				T_FILTERED_GAMES = GetFilteredByKey(T_GAMES, S_VDF_KEY_NAME, S_NAME_FILTER)
			elseif S_TAGS_FILTER ~= '' then
				T_FILTERED_GAMES = GetFilteredByTags(T_GAMES)
			else
				T_FILTERED_GAMES = T_GAMES
			end
			N_SCROLL_START_INDEX = ScrollStartIndexOld
			SortByState(T_FILTERED_GAMES)
			PopulateMeters(T_FILTERED_GAMES)
		end
	end
end

-- Settings
	function GetSettings(abOld)
		local tResult = {}
		if abOld then
			tResult[S_USER_SETTING_KEY_WIDTH] = SKIN:GetVariable('OldBannerWidth', nil)
			tResult[S_USER_SETTING_KEY_HEIGHT] = SKIN:GetVariable('OldBannerHeight', nil)			
			tResult[S_USER_SETTING_KEY_SLOTS] = SKIN:GetVariable('OldSlotCount', nil)
			tResult[S_USER_SETTING_KEY_ORIENTATION] = SKIN:GetVariable('OldOrientation', nil)
			tResult[S_USER_SETTINGS_KEY_HIDE_MESSAGES] = SKIN:GetVariable('OldHideMessages', nil)
		else
			tResult[S_USER_SETTING_KEY_WIDTH] = SKIN:GetVariable('BannerWidth', '274')
			tResult[S_USER_SETTING_KEY_HEIGHT] = SKIN:GetVariable('BannerHeight', '128')
			tResult[S_USER_SETTING_KEY_SLOTS] = SKIN:GetVariable('SlotCount', '5')
			tResult[S_USER_SETTING_KEY_ORIENTATION] = SKIN:GetVariable('Orientation', '0')
			tResult[S_USER_SETTINGS_KEY_HIDE_MESSAGES] = SKIN:GetVariable('HideMessages', '-1')
		end
		return tResult
	end

	function SettingsHaveChanged(atNew, atOld)
		for sKey, sValue in pairs(atNew) do
			if atNew[sKey] ~= atOld[sKey] then
				return true
			end
		end
		return false
	end

	function StoreSettings(atNew)
		local fVariables = io.open((S_PATH_RESOURCES .. S_INCLUDE_FILE_VARIABLES), 'w')
		if fVariables ~= nil then
			fVariables:write('[Variables]\n')
			for sKey, sValue in pairs(atNew) do
				fVariables:write('Old' .. sKey .. '=' .. sValue .. '\n')
			end
			fVariables:write('\n')
			fVariables:close()
		end
	end

-- Meter and variable generation
	function GenerateMetersAndVariables()
		local fMeters = io.open((S_PATH_RESOURCES .. S_INCLUDE_FILE_METERS), 'w')
		if fMeters ~= nil then
			fMeters:close()
		end
		local fVariables = io.open((S_PATH_RESOURCES .. S_INCLUDE_FILE_VARIABLES), 'a+')
		if fVariables ~= nil then
			fVariables:close()
		end
		local n = 0
		for j = 1, tonumber(T_SETTINGS[S_USER_SETTING_KEY_SLOTS]) do
			n = n + 1
			GenerateMeter(n)
			GenerateVariable(n)
		end
	end

	function GenerateMeter(anIndex)
		local fMeters = io.open((S_PATH_RESOURCES .. S_INCLUDE_FILE_METERS), 'a+')
		if fMeters ~= nil then
			fMeters:write('[Game' .. anIndex .. ']\n')
			fMeters:write('Meter=Image\n')
			fMeters:write('ImageName=#@#' .. S_BANNER_FOLDER_NAME .. '\\#' .. S_BANNER_VARIABLE_PREFIX .. anIndex .. '#\n')
			fMeters:write('W=' .. T_SETTINGS[S_USER_SETTING_KEY_WIDTH] .. '\n')
			fMeters:write('H=' .. T_SETTINGS[S_USER_SETTING_KEY_HEIGHT] .. '\n')
			if T_SETTINGS[S_USER_SETTING_KEY_ORIENTATION] == '0' then
				if anIndex == 1 then
					fMeters:write('Y=0\n')
				else
					fMeters:write('Y=0R\n')
				end
				fMeters:write('X=0\n')
			else
				if anIndex == 1 then
					fMeters:write('X=0\n')
				else
					fMeters:write('X=0R\n')
				end
				fMeters:write('Y=0\n')
			end
			fMeters:write('ImageAlpha=#BannerOpacity#\n')
			fMeters:write('DynamicVariables=1\n')
			fMeters:write('SolidColor=#BackgroundColor#\n')
			fMeters:write('PreserveAspectRatio=1\n')
			fMeters:write('LeftMouseUpAction=[!CommandMeasure LauncherScript "LaunchGame(\'#' .. S_BANNER_VARIABLE_PREFIX .. anIndex .. '#\')"]\n')
			fMeters:write('MiddleMouseDoubleClickAction=[!CommandMeasure LauncherScript "AddToExceptions(\'#' .. S_BANNER_VARIABLE_PREFIX .. anIndex .. '#\')"]\n')
			fMeters:write('Group=GameMeters\n')
			fMeters:write('\n')
			fMeters:close()
		end
	end

	function GenerateVariable(anIndex)
		local fVariables = io.open((S_PATH_RESOURCES .. S_INCLUDE_FILE_VARIABLES), 'a+')
		if fVariables ~= nil then
			fVariables:write(S_BANNER_VARIABLE_PREFIX .. anIndex .. '=blank.png\n')
			fVariables:close()
		end
	end

-- Generating game objects
	function GenerateGames()
		local tGames = {}

		-- Non-Steam games
		local tNonSteamGames = ParseVDFFile(S_PATH_RESOURCES .. S_INCLUDE_FILE_NON_STEAM_GAMES)
		if tNonSteamGames ~= nil then
			for sKey, sValue in pairs(tNonSteamGames) do
				local tGame = {}
				tGame[S_VDF_KEY_APPID] = sValue[S_VDF_KEY_APPID]
				tGame[S_VDF_KEY_NAME] = sValue[S_VDF_KEY_NAME]
				tGame[S_VDF_KEY_TAGS] = sValue[S_VDF_KEY_TAGS]
				tGame[S_VDF_KEY_PATH] = sValue[S_VDF_KEY_PATH]
				tGame[S_VDF_KEY_LAST_PLAYED] = sValue[S_VDF_KEY_LAST_PLAYED]
				if tGame[S_VDF_KEY_LAST_PLAYED] == nil then
					tGame[S_VDF_KEY_LAST_PLAYED] = '0'
				end
				if BannerExists(tGame[S_VDF_KEY_APPID]) == nil then
					if tonumber(tGame[S_VDF_KEY_APPID]) ~= nil then
						DisplayMessage('Missing banner#CRLF#' .. tGame[S_VDF_KEY_APPID] .. '#CRLF#for#CRLF#' .. tGame[S_VDF_KEY_NAME])
						table.insert(T_LOGO_QUEUE, tGame[S_VDF_KEY_APPID])
						table.insert(tGames, tGame)
					else
						DisplayMessage('Missing banner#CRLF#' .. tGame[S_VDF_KEY_APPID] .. '#CRLF#for#CRLF#' .. tGame[S_VDF_KEY_NAME])
					end
				else
					table.insert(tGames, tGame)
				end
				tGame = nil
			end
			tNonSteamGames = nil
		end

		local tSteamLibraryPaths = {}
		table.insert(tSteamLibraryPaths, S_PATH_STEAM)
		if S_PATH_STEAM_LIBRARIES ~= nil then
			for sLibraryPath in S_PATH_STEAM_LIBRARIES:gmatch('([^;]+)') do
				if sLibraryPath ~= nil then
					if sLibraryPath ~= '' and EndsWith(sPath, '\\') == false then
						sLibraryPath = sLibraryPath .. '\\'
					end
					sLibraryPath = Trim(sLibraryPath)
				end
				table.insert(tSteamLibraryPaths, sLibraryPath)
			end
		end
		
		-- Steam games and non-Steam games that have been added to the Steam library.
		if S_PATH_STEAM ~= nil and S_PATH_STEAM ~= '' then
			if S_STEAM_USER_DATA_ID == nil or S_STEAM_USER_DATA_ID == '' then
				DisplayMessage('Missing Steam UserDataID#CRLF#or invalid Steam path')
			else
				local tLocalConfigApps = ParseVDFFile(S_PATH_STEAM .. 'userdata\\' .. S_STEAM_USER_DATA_ID ..'\\config\\localconfig.vdf')
				if tLocalConfigApps == nil then
					DisplayMessage('Invalid Steam UserDataID#CRLF#and/or Steam path')
				else
					local tLocalConfigAppTickets = tLocalConfigApps[S_VDF_KEY_USER_LOCAL_CONFIG_STORE][S_VDF_KEY_APP_TICKETS]
					tLocalConfigApps = tLocalConfigApps[S_VDF_KEY_USER_LOCAL_CONFIG_STORE][S_VDF_KEY_SOFTWARE][S_VDF_KEY_VALVE][S_VDF_KEY_STEAM][S_VDF_KEY_APPS]
					local tSharedConfigApps = ParseVDFFile(S_PATH_STEAM .. 'userdata\\' .. S_STEAM_USER_DATA_ID .. '\\7\\remote\\sharedconfig.vdf')
					tSharedConfigApps = tSharedConfigApps[S_VDF_KEY_USER_LOCAL_CONFIG_STORE][S_VDF_KEY_SOFTWARE][S_VDF_KEY_VALVE][S_VDF_KEY_STEAM][S_VDF_KEY_APPS]
					local tExceptions = ParseVDFFile(S_PATH_RESOURCES .. S_INCLUDE_FILE_EXCEPTIONS)
					if tLocalConfigApps ~= nil and tLocalConfigAppTickets ~= nil and tSharedConfigApps ~= nil then

						for i = 1, #tSteamLibraryPaths do

							-- Steam games.
							for sAppID, tTable in pairs(tLocalConfigAppTickets) do
								if tExceptions[sAppID] == nil then
									local tGame = {}
									tGame[S_VDF_KEY_STEAM] = 'true'
									tGame[S_VDF_KEY_APPID] = sAppID
									if tLocalConfigApps[sAppID] ~= nil and tLocalConfigApps[sAppID][S_VDF_KEY_LAST_PLAYED] ~= nil then
										tGame[S_VDF_KEY_LAST_PLAYED] = tLocalConfigApps[sAppID][S_VDF_KEY_LAST_PLAYED]
										local tAppManifest = ParseVDFFile(tSteamLibraryPaths[i] .. 'SteamApps\\appmanifest_' .. sAppID .. '.acf')
										if tAppManifest ~= nil then
											tGame[S_VDF_KEY_NAME] = tAppManifest[S_VDF_KEY_APP_STATE][S_VDF_KEY_NAME]
											if tGame[S_VDF_KEY_NAME] == nil then
												tGame[S_VDF_KEY_NAME] = tAppManifest[S_VDF_KEY_APP_STATE][S_VDF_KEY_USER_CONFIG][S_VDF_KEY_NAME]
											end
											local tGameSharedConfig = RecursiveTableSearch(tSharedConfigApps, sAppID)
											if tGameSharedConfig ~= nil then
												tGame[S_VDF_KEY_TAGS] = RecursiveTableSearch(tGameSharedConfig, S_VDF_KEY_TAGS)
												tGame[S_VDF_KEY_HIDDEN] = tGameSharedConfig[S_VDF_KEY_HIDDEN]
											end
											tGameSharedConfig = nil
											if tGame[S_VDF_KEY_HIDDEN] == nil or tGame[S_VDF_KEY_HIDDEN] == '0' then
												table.insert(tGames, tGame)
												if BannerExists(tGame[S_VDF_KEY_APPID]) == nil then
													table.insert(T_LOGO_QUEUE, tGame[S_VDF_KEY_APPID])
												end
											end
										end
									end
									tGame = nil
								end
							end

						end

						-- Non-Steam games that have been added to the Steam library.
						local sShortcuts = ''
						-- Convert from hexadecimal to UTF8. Replace control characters with "|".
						local fShortcuts = io.open((S_PATH_STEAM .. 'userdata\\' .. S_STEAM_USER_DATA_ID ..'\\config\\shortcuts.vdf'), 'rb')
						if fShortcuts ~= nil then
							while true do
								local sHex = fShortcuts:read(5)
								if sHex == nil then
									fShortcuts:close()
									break
								else
									sShortcuts = sShortcuts .. string.gsub(sHex, '%c', '|')
								end
							end
							local tSteamShortcuts = ParseVDFFile(S_PATH_RESOURCES .. S_INCLUDE_FILE_STEAM_SHORTCUTS)
							local nSteamShortcutsBefore = 0
							for k,v in pairs(tSteamShortcuts) do
								nSteamShortcutsBefore = nSteamShortcutsBefore + 1
							end
							for sName, sPath, sTags in string.gmatch(sShortcuts, '|appname|([^|]+)||exe|\"(.-)\"|.-|tags|(.-)||||') do
								local nIndex = 0
								local nMaxIndex = 0
								if tSteamShortcuts ~= nil then
									for sKey, tValue in pairs(tSteamShortcuts) do
										local nKey = tonumber(sKey)
										if tValue[S_VDF_KEY_NAME] == sName then
											nIndex = nKey
											break
										elseif nKey >= nMaxIndex then
											nMaxIndex = nKey + 1
										end
									end
								end
								local tGame = {}
								tGame[S_VDF_KEY_APPID] = sName
								tGame[S_VDF_KEY_NAME] = sName
								tGame[S_VDF_KEY_PATH] = sPath
								tGame[S_VDF_KEY_STEAM_SHORTCUT] = 'true'
								tGame[S_VDF_KEY_LAST_PLAYED] = '0'
								local tTags = {}
								local nTags = 0
								for sTag in string.gmatch(sTags, '|+%d+|([^|]+)') do
									tTags[tostring(nTags)] = sTag
									nTags = nTags + 1
								end
								if nTags > 0 then
									tGame[S_VDF_KEY_TAGS] = tTags
								end
								local sMaxIndex = tostring(nMaxIndex)
								if tSteamShortcuts[sMaxIndex] == nil then
									local tLocalGame = {}
									tLocalGame[S_VDF_KEY_NAME] = sName
									tLocalGame[S_VDF_KEY_LAST_PLAYED] = '0'
									tSteamShortcuts[sMaxIndex] = tLocalGame
								else
									local sIndex = tostring(nIndex)
									tGame[S_VDF_KEY_LAST_PLAYED] = tSteamShortcuts[sIndex][S_VDF_KEY_LAST_PLAYED]
									if tSteamShortcuts[sIndex][S_VDF_KEY_PATH] ~= nil then
										tGame[S_VDF_KEY_PATH] = tSteamShortcuts[sIndex][S_VDF_KEY_PATH]
									end
									if tSteamShortcuts[sIndex][S_VDF_KEY_STEAM] ~= nil then
										tGame[S_VDF_KEY_STEAM] = tSteamShortcuts[sIndex][S_VDF_KEY_STEAM]
									end

									if tSteamShortcuts[sIndex][S_VDF_KEY_APPID] ~= nil then
										tGame[S_VDF_KEY_APPID] = tSteamShortcuts[sIndex][S_VDF_KEY_APPID]
									end

								end
								if BannerExists(tGame[S_VDF_KEY_APPID]) == nil then
									if tonumber(tGame[S_VDF_KEY_APPID]) ~= nil then
										table.insert(T_LOGO_QUEUE, tGame[S_VDF_KEY_APPID])
										table.insert(tGames, tGame)
									else
										DisplayMessage('Missing banner#CRLF#' .. tGame[S_VDF_KEY_APPID] .. '#CRLF#for#CRLF#' .. tGame[S_VDF_KEY_NAME])
									end
								else
									table.insert(tGames, tGame)
								end
							end
							local nSteamShortcutsAfter = 0
							for k,v in pairs(tSteamShortcuts) do
								nSteamShortcutsAfter = nSteamShortcutsAfter + 1
							end
							if nSteamShortcutsBefore ~= nSteamShortcutsAfter then
								SerializeTableAsVDFFile(tSteamShortcuts, (S_PATH_RESOURCES .. S_INCLUDE_FILE_STEAM_SHORTCUTS))
							end
							tSteamShortcuts = nil
						end
					end
				end
			end
		end
		if #tGames > 0 then
			AcquireBanner()
		end
		return tGames
	end

-- Refresh banners
	function PopulateMeters(atGames)
		j = N_SCROLL_START_INDEX
		for i = 1, tonumber(T_SETTINGS[S_USER_SETTING_KEY_SLOTS]) do
			if j > 0 and j <= #atGames then
				local sExtension = BannerExists(atGames[j][S_VDF_KEY_APPID])
				if sExtension ~= nil then
					if j > #atGames then
						SKIN:Bang('!SetVariable ' .. S_BANNER_VARIABLE_PREFIX .. i .. ' "blank.png"')
					else
						SKIN:Bang('!SetVariable ' .. S_BANNER_VARIABLE_PREFIX .. i .. ' "' .. atGames[j][S_VDF_KEY_APPID] .. sExtension .. '"')
					end
				end
				j = j + 1
			else
				SKIN:Bang('!SetVariable ' .. S_BANNER_VARIABLE_PREFIX .. i .. ' "blank.png"')
			end
		end
		SKIN:Bang('[!UpdateMeterGroup GameMeters][!Redraw]')
		AcquireBanner()
	end

	function Scroll(asAmount)
		local anStart = N_SCROLL_START_INDEX
		local anMaxScroll = #T_FILTERED_GAMES - tonumber(T_SETTINGS[S_USER_SETTING_KEY_SLOTS]) + 1
		local anAmount = tonumber(asAmount) * N_SCROLL_MULTIPLIER
		N_SCROLL_START_INDEX = N_SCROLL_START_INDEX + anAmount
		if N_SCROLL_START_INDEX < 1 or #T_FILTERED_GAMES < tonumber(T_SETTINGS[S_USER_SETTING_KEY_SLOTS]) then
			N_SCROLL_START_INDEX = 1
		elseif N_SCROLL_START_INDEX >  anMaxScroll then
			N_SCROLL_START_INDEX = anMaxScroll
		end
		if N_SCROLL_START_INDEX ~= anStart then
			PopulateMeters(T_FILTERED_GAMES)
		end
	end

-- Acquire banners
	function BannerExists(asAppID)
		for i = 1, #T_SUPPORTED_BANNER_EXTENSIONS do
			local fBanner = io.open((S_PATH_RESOURCES .. S_BANNER_FOLDER_NAME .. '\\' .. asAppID .. T_SUPPORTED_BANNER_EXTENSIONS[i]), 'r')
			if fBanner ~= nil then
				fBanner:close()
				return T_SUPPORTED_BANNER_EXTENSIONS[i]
			end
		end
		return nil
	end

	function AcquireBanner()
		if #T_LOGO_QUEUE > 0 then
			local tExceptions = ParseVDFFile(S_PATH_RESOURCES .. S_INCLUDE_FILE_EXCEPTIONS)
			while #T_LOGO_QUEUE > 0 and tExceptions[T_LOGO_QUEUE[1]] ~= nil do
				table.remove(T_LOGO_QUEUE, 1)
			end
			tExceptions = nil
			if #T_LOGO_QUEUE > 0 then
				for i = 1, #T_GAMES do
					if T_GAMES[S_VDF_KEY_APPID] == T_LOGO_QUEUE[1] then
						DisplayMessage('Downloading banner#CRLF#' .. T_GAMES[S_VDF_KEY_NAME])
						break
					end
				end
				SKIN:Bang('[!SetVariable LogoToDownload "' .. T_LOGO_QUEUE[1] .. '"][!SetOption LogoDownloader Disabled "0"][!CommandMeasure LogoDownloader Update]')
			end
		end
	end

	function BannerAcquisitionEnded(anStatus)
		anStatus = tonumber(anStatus)
		--[[
		anStatus codes
		0 = Successful acquisition
		1 = Failure to connect (file doesn't exist or internet connection is down).
		2 = Failure to download due to e.g. lack of permission to write.
		--]]
		if anStatus >= 0 then
			if anStatus == 0 then
				if #T_LOGO_QUEUE > 0 then
					local sFileName = T_LOGO_QUEUE[1] .. '.jpg'
					local sOldFilePath = S_PATH_DOWNLOADS .. sFileName
					local sNewFilePath = S_PATH_RESOURCES .. S_BANNER_FOLDER_NAME .. '\\' .. sFileName
					os.rename(sOldFilePath, sNewFilePath)
					if S_NAME_FILTER ~= '' then
						T_FILTERED_GAMES = GetFilteredByKey(T_GAMES, S_VDF_KEY_NAME, S_NAME_FILTER)
					elseif S_TAGS_FILTER ~= '' then
						T_FILTERED_GAMES = GetFilteredByTags(T_GAMES)
					else
						T_FILTERED_GAMES = T_GAMES
					end
					SortByState(T_FILTERED_GAMES)
					PopulateMeters(T_FILTERED_GAMES)
				end
			else
				local tExceptions = ParseVDFFile(S_PATH_RESOURCES .. S_INCLUDE_FILE_EXCEPTIONS)
				if tExceptions[T_LOGO_QUEUE[1]] == nil then
					local sName = 'Unknown'
					for i = 1, #T_GAMES do
						if T_GAMES[i][S_VDF_KEY_APPID] == T_LOGO_QUEUE[1] then
							sName = T_GAMES[i][S_VDF_KEY_NAME]
							break
						end
					end
					tExceptions[T_LOGO_QUEUE[1]] = sName
					SerializeTableAsVDFFile(tExceptions, (S_PATH_RESOURCES .. S_INCLUDE_FILE_EXCEPTIONS))
					DisplayMessage('Download failed#CRLF#' .. sName)
				end
			end
			table.remove(T_LOGO_QUEUE, 1)
			if #T_LOGO_QUEUE > 0 then
				AcquireBanner()
			else
				HideMessage()
				SKIN:Bang('[!Refresh]')
			end
		end
	end

-- Sorting lists of game objects
	function SortAlphabetically(atFirst, atSecond)
		if atFirst[S_VDF_KEY_NAME]:gsub(':', ' ') < atSecond[S_VDF_KEY_NAME]:gsub(':', ' ') then
			return true
		else
			return false
		end
	end

	function SortLastPlayed(atFirst, atSecond)
		if tonumber(atFirst[S_VDF_KEY_LAST_PLAYED]) > tonumber(atSecond[S_VDF_KEY_LAST_PLAYED]) then
			return true
		else
			return false
		end
	end

	function SortGames()
		N_SORT_STATE = N_SORT_STATE + 1
		SortByState(T_FILTERED_GAMES)
		PopulateMeters(T_FILTERED_GAMES)
	end

	function SortByState(atGames)
		if N_SORT_STATE > 1 then
			N_SORT_STATE = 0
		end
		if N_SORT_STATE == 0 then
			table.sort(atGames, SortAlphabetically)
			SKIN:Bang('!SetOption SkinSorting ImageName "#@#SortAlphabetically.png"')
		elseif N_SORT_STATE == 1 then
			table.sort(atGames, SortLastPlayed)
			SKIN:Bang('!SetOption SkinSorting ImageName "#@#SortLastPlayed.png"')
		end
		SKIN:Bang('!UpdateMeterGroup SortingButton')
	end

	function Filter(asFilter)
		asFilter = asFilter:lower()
		local bAdditive = false
		if StartsWith(asFilter, '+') then
			bAdditive = true
			asFilter = asFilter:sub(2)
		end
		if StartsWith(asFilter, 'tags:') then
			asFilter = Trim(asFilter:sub(6))
			S_TAGS_FILTER = asFilter
			S_NAME_FILTER = ''
			if bAdditive == true then
				T_FILTERED_GAMES = GetFilteredByTags(T_FILTERED_GAMES)
			else
				T_FILTERED_GAMES = GetFilteredByTags(T_GAMES)
			end
			SortByState(T_FILTERED_GAMES)
			PopulateMeters(T_FILTERED_GAMES)
		elseif StartsWith(asFilter, 'steam:') then
			asFilter = Trim(asFilter:sub(7))
			if asFilter == 'true' then
				if bAdditive == true then
					T_FILTERED_GAMES = GetFilteredByKey(T_FILTERED_GAMES, S_VDF_KEY_STEAM, 'true')
				else
					T_FILTERED_GAMES = GetFilteredByKey(T_GAMES, S_VDF_KEY_STEAM, 'true')
				end
				SortByState(T_FILTERED_GAMES)
				PopulateMeters(T_FILTERED_GAMES)
			elseif asFilter == 'false' then
				if bAdditive == true then
					T_FILTERED_GAMES = GetFilteredByKey(T_FILTERED_GAMES, S_VDF_KEY_STEAM, 'false')
				else
					T_FILTERED_GAMES = GetFilteredByKey(T_GAMES, S_VDF_KEY_STEAM, 'false')
				end
				SortByState(T_FILTERED_GAMES)
				PopulateMeters(T_FILTERED_GAMES)
			end
		else
			asFilter = Trim(asFilter)
			S_NAME_FILTER = asFilter
			S_TAGS_FILTER = ''
			if bAdditive == true then
				T_FILTERED_GAMES = GetFilteredByKey(T_FILTERED_GAMES, S_VDF_KEY_NAME, S_NAME_FILTER)
			else
				T_FILTERED_GAMES = GetFilteredByKey(T_GAMES, S_VDF_KEY_NAME, S_NAME_FILTER)
			end
			SortByState(T_FILTERED_GAMES)
			PopulateMeters(T_FILTERED_GAMES)
		end
	end

	function GetFilteredByTags(atSelection)
		N_SCROLL_START_INDEX = 1
		if S_TAGS_FILTER == nil or S_TAGS_FILTER == '' then
			return T_GAMES
		else
			local tTags = {}
			for sTag in string.gmatch(S_TAGS_FILTER, "([^;]+)") do
				table.insert(tTags, Trim(sTag))
			end
			local tFilteredGames = {}
			for i = 1, #atSelection do
				if atSelection[i][S_VDF_KEY_TAGS] ~= nil then
					local tTagsCopy = {}
					for j = 1, #tTags do
						table.insert(tTagsCopy, tTags[j])
					end
					for sKey, sTag in pairs(atSelection[i][S_VDF_KEY_TAGS]) do
						for j = #tTagsCopy, 1, -1 do
							if (sTag:lower()):match(tTagsCopy[j]) then
								table.remove(tTagsCopy, j)
							end
						end
					end
					if #tTagsCopy == 0 then
						table.insert(tFilteredGames, atSelection[i])
					end
				end
			end
			return tFilteredGames
		end
	end

	function GetFilteredByKey(atSelection, asKey, asValue)
		N_SCROLL_START_INDEX = 1
		if asValue == nil or asValue == '' then
			return T_GAMES
		else
			local tFilteredGames = {}
			asValue = asValue:lower()
			if asKey == S_VDF_KEY_STEAM then
				if asValue == 'true' then
					for i = 1, #atSelection do
						if atSelection[i][asKey] == 'true' then
							table.insert(tFilteredGames, atSelection[i])
						end
					end
				elseif asValue == 'false' then
					for i = 1, #atSelection do
						if atSelection[i][asKey] == nil or atSelection[i][asKey] == 'false' then
							table.insert(tFilteredGames, atSelection[i])
						end
					end
				end
			else
				
				for i = 1, #atSelection do
					if atSelection[i][asKey] ~= nil and string.find(atSelection[i][asKey]:lower(), asValue) then
						table.insert(tFilteredGames, atSelection[i])
					end
				end
			end
			return tFilteredGames
		end
	end

-- Meter functionality
	function LaunchGame(asAppID)
		asAppID = string.sub(asAppID, 1, (string.find(asAppID, '%.') - 1))
		if asAppID ~= 'blank' then
			for i = 1, #T_GAMES do
				if asAppID == T_GAMES[i][S_VDF_KEY_APPID] then
					T_GAMES[i][S_VDF_KEY_LAST_PLAYED] = os.time()
					if T_GAMES[i][S_VDF_KEY_STEAM] == 'true' and T_GAMES[i][S_VDF_KEY_PATH] == nil then
						SKIN:Bang('[' .. S_STEAM_RUN_COMMAND .. asAppID .. ']')
					else
						local tLocal = ParseVDFFile(S_PATH_RESOURCES .. S_INCLUDE_FILE_NON_STEAM_GAMES)
						if T_GAMES[i][S_VDF_KEY_STEAM_SHORTCUT] == 'true' then
							tLocal = ParseVDFFile(S_PATH_RESOURCES .. S_INCLUDE_FILE_STEAM_SHORTCUTS)
						else
							tLocal = ParseVDFFile(S_PATH_RESOURCES .. S_INCLUDE_FILE_NON_STEAM_GAMES)
						end
						if tLocal ~= nil then
							for sKey, tValue in pairs(tLocal) do
								if tValue[S_VDF_KEY_APPID] == asAppID then
									tValue[S_VDF_KEY_LAST_PLAYED] = T_GAMES[i][S_VDF_KEY_LAST_PLAYED]
									break
								end
							end
							if T_GAMES[i][S_VDF_KEY_STEAM_SHORTCUT] == 'true' then
								SerializeTableAsVDFFile(tLocal, (S_PATH_RESOURCES .. S_INCLUDE_FILE_STEAM_SHORTCUTS))
							else
								SerializeTableAsVDFFile(tLocal, (S_PATH_RESOURCES .. S_INCLUDE_FILE_NON_STEAM_GAMES))
							end
							tLocal = nil
						end
						if T_GAMES[i][S_VDF_KEY_PATH] ~= nil then
							SKIN:Bang('["' .. T_GAMES[i][S_VDF_KEY_PATH] .. '"]')
						end
					end
					SortByState(T_FILTERED_GAMES)
					PopulateMeters(T_FILTERED_GAMES)
					break
				end
			end
		end
	end

	function AddToExceptions(asAppID)
		asAppID = string.sub(asAppID, 1, (string.find(asAppID, '%.') - 1))
		for i = 1, #T_GAMES do
			if asAppID == T_GAMES[i][S_VDF_KEY_APPID] then
				if T_GAMES[i][S_VDF_KEY_STEAM] == 'true' then
					local tExceptions = ParseVDFFile(S_PATH_RESOURCES .. S_INCLUDE_FILE_EXCEPTIONS)
					if tExceptions[asAppID] == nil then
						local sName = T_GAMES[i][S_VDF_KEY_NAME]
						tExceptions[asAppID] = sName
						SerializeTableAsVDFFile(tExceptions, (S_PATH_RESOURCES .. S_INCLUDE_FILE_EXCEPTIONS))
						Update()
						break
					end
				end
			end
		end
	end

-- VDF (de)serializing
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
			sKey = string.match(atTable[i], '^%s*"([^"]+)"%s*$')
			if sKey ~= nil then
				i = i + 1
				if string.match(atTable[i], '^%s*{%s*$') then
					sValue, i = ParseVDFTable(atTable, (i + 1))
					if sValue == nil and i == nil then
						return nil, nil
					else
						tResult[sKey] = sValue
					end
				else
					print('Error! Malformed tables at line ' .. tostring(i) .. '(' .. atTable[i] .. ')')
					return nil, nil
				end
			else
				sKey = string.match(atTable[i], '^%s*"([^"]+)"%s*"[^"]*"%s*$')
				if sKey ~= nil then
					sValue = string.match(atTable[i], '^%s*"[^"]+"%s*"([^"]+)"%s*$')
					tResult[sKey] = sValue
				else
					if string.match(atTable[i], '^%s*}%s*$') then
						return tResult, i
					elseif string.match(atTable[i], '^%s*//.*$') then
						-- Comment - Better support is still needed for comments
					else
						sValue = string.match(atTable[i], '^%s*"#base"%s*"([^"]+)"%s*$')
						if sValue ~= nil then
							-- Base - Needs to be implemented
						else
							print('Error! Malformed tables at line ' .. tostring(i) .. '(' .. atTable[i] .. ')')
							return nil, nil
						end
					end
				end
			end
			i = i + 1
		end
		return tResult, i
	end

	function ParseVDFFile(asFile)
		local fFile = io.open(asFile, 'r')
		local tTable = {}
		if fFile ~= nil then
			for sLine in fFile:lines() do
				table.insert(tTable, sLine)
			end
			fFile:close()
		else
			return nil
		end
		return ParseVDFTable(tTable)
	end

	function SerializeTableAsVDF(atTable)
		assert(type(atTable) == 'table')
		local tResult = {}
		for sKey, Value in pairs(atTable) do
			local sType = type(Value)
			if sType == 'table' then
				table.insert(tResult, (S_VDF_SERIALIZING_INDENTATION .. '"' .. tostring(sKey) .. '"'))
				table.insert(tResult, (S_VDF_SERIALIZING_INDENTATION .. '{'))
				S_VDF_SERIALIZING_INDENTATION = S_VDF_SERIALIZING_INDENTATION .. '\t\t'
				local tTemp = SerializeTableAsVDF(Value)
				for i = 1, #tTemp do
					table.insert(tResult, tTemp[i])
				end
				S_VDF_SERIALIZING_INDENTATION = string.sub(S_VDF_SERIALIZING_INDENTATION, 3)
				table.insert(tResult, (S_VDF_SERIALIZING_INDENTATION .. '}'))
			elseif sType == 'number' or sType == 'string' then
				table.insert(tResult, (S_VDF_SERIALIZING_INDENTATION .. '"' .. tostring(sKey) .. '"\t\t"' .. tostring(Value) .. '"'))
			else
				print('ERROR! Unsupported data type (' .. sType .. ')')
			end
		end
		return tResult
	end

	function SerializeTableAsVDFFile(atTable, asFile)
		local tResult = SerializeTableAsVDF(atTable)
		local fFile = assert(io.open(asFile, 'w'))
		for i = 1, #tResult do
			fFile:write(tResult[i] .. '\n')
		end
		fFile:close()
	end

-- Utility
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

-- Toolbar
	function ShowToolbar()
		B_SHOW_TOOLBAR = true
		if B_FORCE_SHOW_TOOLBAR == false then
			SKIN:Bang('[!ShowMeterGroup Toolbar][!Redraw]')
		end
	end

	function HideToolbar()
		B_SHOW_TOOLBAR = false
		if B_FORCE_SHOW_TOOLBAR == false then
			SKIN:Bang('[!HideMeterGroup Toolbar][!Redraw]')
		end
	end

	function ForceShowToolbar(abState)
		B_FORCE_SHOW_TOOLBAR = abState
		if B_SHOW_TOOLBAR == false then
			SKIN:Bang('[!HideMeterGroup Toolbar][!Redraw]')
		end
	end

-- Displaying messages
	function DisplayMessage(asMessage)
		if T_SETTINGS[S_USER_SETTINGS_KEY_HIDE_MESSAGES] == '0' then
			if B_SHOWING_MESSAGE == false then
				B_SHOWING_MESSAGE = true
				SKIN:Bang('[!SetVariable MessageOverlayText \"' .. asMessage .. '\"][!UpdateMeterGroup MessageOverlay][!ShowMeterGroup MessageOverlay][!Redraw]')
			end
		end
	end

	function HideMessage()
		SKIN:Bang('[!HideMeterGroup MessageOverlay][!Redraw]')
	end
