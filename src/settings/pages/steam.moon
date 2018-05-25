utility = require('shared.utility')
Page = require('settings.pages.page')
Settings = require('settings.types')

state = {
	accounts: {}
}

getUsers = () ->
	path = io.joinPaths(COMPONENTS.SETTINGS\getSteamPath(), 'config\\loginusers.vdf')
	return nil unless io.fileExists(path, false)
	vdf = utility.parseVDF(io.readFile(path, false))
	return nil if vdf == nil or vdf.users == nil
	for communityID, user in pairs(vdf.users)
		user.personaname = utility.replaceUnsupportedChars(user.personaname)
	return vdf.users

getPersonaName = (accountID) ->
	path = io.joinPaths(COMPONENTS.SETTINGS\getSteamPath(), 'userdata', accountID, 'config\\localconfig.vdf')
	return nil unless io.fileExists(path, false)
	vdf = utility.parseVDF(io.readFile(path, false))
	config = vdf.userroamingconfigstore
	config = vdf.userlocalconfigstore if config == nil
	return nil if config == nil
	return nil if config.friends == nil
	return utility.replaceUnsupportedChars(config.friends.personaname)

updateUsers = () -> 
	state.accounts = {}
	path = 'cache\\steam\\users.txt'
	if io.fileExists(path)
		users = io.readFile(path)
		accountIDs = users\splitIntoLines()
		users = getUsers()
		for accountID in *accountIDs
			personaName = getPersonaName(accountID)
			continue if personaName == nil
			for communityID, user in pairs(users)
				if user.personaname == personaName
					table.insert(state.accounts, {
						:accountID
						:communityID 
						:personaName
						displayValue: personaName
					})
					users[communityID] = nil
					break
	if #state.accounts == 0
		state.accounts[1] = {
			accountID: ''
			communityID: ''
			personaName: ''
			displayValue: ''
		}

getUserIndex = () ->
	for i, account in ipairs(state.accounts)
		log('checking account ' .. i .. ': ' .. account.personaName)
		if account.accountID == COMPONENTS.SETTINGS\getSteamAccountID()
			log('account index is ' .. i)
			return i
	return 1

class Steam extends Page
	new: () =>
		super()
		@title = 'Steam'
		updateUsers()
		steamClientPathDescription = LOCALIZATION\get('setting_steam_client_path_description', 'This should be the folder that contains the Steam client executable.')
		@settings = {
			Settings.Boolean({
				title: LOCALIZATION\get('button_label_enabled', 'Enabled')
				tooltip: LOCALIZATION\get('setting_steam_enabled_description', 'If enabled, then games installed via the Steam client will be included. Non-Steam game shortcuts that have been added to Steam will also be included.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleSteamEnabled()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getSteamEnabled()
			})
			Settings.FolderPath({
				title: LOCALIZATION\get('button_label_client_path', 'Client path')
				tooltip: steamClientPathDescription
				getValue: () =>
					return COMPONENTS.SETTINGS\getSteamPath()
				setValue: (path) =>
					return COMPONENTS.SETTINGS\setSteamPath(path)
				dialogTitle: steamClientPathDescription
			})
			Settings.Spinner({
				title: LOCALIZATION\get('setting_steam_account_title', 'Account')
				tooltip: LOCALIZATION\get('setting_steam_account_description', 'Choose the Steam account whose games to get.')
				index: getUserIndex()
				setIndex: (index) =>
					if index < 1
						index = #@getValues()
					elseif index > #@getValues()
						index = 1
					@index = index
					account = @getValues()[@index]
					COMPONENTS.SETTINGS\setSteamAccountID(account.accountID)
					COMPONENTS.SETTINGS\setSteamCommunityID(account.communityID)
				getValues: () =>
					return state.accounts
				setValues: () =>
					updateUsers()
					@setIndex(getUserIndex())
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_steam_community_profile_title', 'Parse community profile')
				tooltip: LOCALIZATION\get('setting_steam_community_profile_description', "If enabled, then the Steam community profile will be downloaded and parsed to get:\n- All games associated with the chosen account even if not installed at the moment.\n- The total hours played of each game associated with the chosen account.\n\nRequires that the Game details setting in the Steam profile's privacy settings is set as public.")
				toggle: () ->
					COMPONENTS.SETTINGS\toggleSteamParseCommunityProfile()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getSteamParseCommunityProfile()
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_starting_bangs', 'Starting bangs')
				tooltip: LOCALIZATION\get('setting_steam_starting_bangs_description', 'These Rainmeter bangs are executed just before any Steam game launches.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getSteamStartingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedSteamStartingBangs')
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_stopping_bangs', 'Stopping bangs')
				tooltip: LOCALIZATION\get('setting_steam_stopping_bangs_description', 'These Rainmeter bangs are executed just after any Steam game terminates.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getSteamStoppingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedSteamStoppingBangs')
			})
		}

return Steam
