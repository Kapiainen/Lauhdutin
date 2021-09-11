utility = require('shared.utility')
Page = require('settings.pages.page')
Settings = require('settings.types')

class GOGGalaxy extends Page
	new: () =>
		super()
		@title = 'GOG Galaxy'
		@settings = {
			Settings.Boolean({
				title: LOCALIZATION\get('button_label_enabled', 'Enabled')
				tooltip: LOCALIZATION\get('setting_gog_galaxy_enabled_description', 'If enabled, then games installed via the GOG Galaxy client will be included.')
				toggle: () =>
					COMPONENTS.SETTINGS\toggleGOGGalaxyEnabled()
					return true
				getState: () =>
					return COMPONENTS.SETTINGS\getGOGGalaxyEnabled()
			})
			Settings.FolderPath({
				title: LOCALIZATION\get('button_label_client_path', 'Client path')
				tooltip: LOCALIZATION\get('setting_gog_galaxy_client_path_description', 'The folder that contains the GOG Galaxy client executable.')
				getValue: () =>
					return COMPONENTS.SETTINGS\getGOGGalaxyClientPath()
				setValue: (path) =>
					return COMPONENTS.SETTINGS\setGOGGalaxyClientPath(path)
				dialogTitle: "Select the folder containing 'GalaxyClient.exe'"
			})
			Settings.FolderPath({
				title: LOCALIZATION\get('setting_gog_galaxy_program_data_path_title', 'ProgramData path')
				tooltip: LOCALIZATION\get('setting_gog_galaxy_program_data_path_description', 'The path where the GOG Galaxy client stores some of its data.')
				getValue: () =>
					return COMPONENTS.SETTINGS\getGOGGalaxyProgramDataPath()
				setValue: (path) =>
					return COMPONENTS.SETTINGS\setGOGGalaxyProgramDataPath(path)
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_gog_galaxy_indirect_launch_title', 'Launch via client')
				tooltip: LOCALIZATION\get('setting_gog_galaxy_indirect_launch_description', "If enabled, then games will be launched via the GOG Galaxy client.\nLaunching via the client allows the client's overlay to be used and for the client to track the amount of time played.")
				toggle: () =>
					COMPONENTS.SETTINGS\toggleGOGGalaxyIndirectLaunch()
					return true
				getState: () =>
					return COMPONENTS.SETTINGS\getGOGGalaxyIndirectLaunch()
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_gog_galaxy_community_profile_title', 'Parse community profile')
				tooltip: LOCALIZATION\get('setting_gog_galaxy_community_profile_description', "If enabled, then the GOG community profile will be downloaded and parsed to get all games associated with the chosen account even if not installed at the moment.\n\nRequires that the profile is set as public.")
				toggle: () =>
					COMPONENTS.SETTINGS\toggleGOGGalaxyParseCommunityProfile()
					return true
				getState: () =>
					return COMPONENTS.SETTINGS\getGOGGalaxyParseCommunityProfile()
			})
			Settings.String({
				title: LOCALIZATION\get('setting_gog_galaxy_community_profile_name_title', 'Community profile name')
				tooltip: LOCALIZATION\get('setting_gog_galaxy_community_profile_name_description', "The name of the GOG profile to download and parse.")
				setValue: (value) =>
					COMPONENTS.SETTINGS\setGOGGalaxyProfileName(value)
					return true
				getValue: () =>
					return COMPONENTS.SETTINGS\getGOGGalaxyProfileName() or ''
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_starting_bangs', 'Starting bangs')
				tooltip: LOCALIZATION\get('setting_gog_galaxy_starting_bangs_description', 'These Rainmeter bangs are executed just before any GOG Galaxy game launches.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getGOGGalaxyStartingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedGOGGalaxyStartingBangs')
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_stopping_bangs', 'Stopping bangs')
				tooltip: LOCALIZATION\get('setting_gog_galaxy_stopping_bangs_description', 'These Rainmeter bangs are executed just after any GOG Galaxy game terminates.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getGOGGalaxyStoppingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedGOGGalaxyStoppingBangs')
			})
		}

return GOGGalaxy
