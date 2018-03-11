utility = require('shared.utility')
Page = require('settings.pages.page')
Settings = require('settings.types')

state = {
	paths: COMPONENTS.SETTINGS\getBattlenetPaths()
}

class Battlenet extends Page
	new: () =>
		super()
		@title = 'Blizzard Battle.net'
		@settings = {
			Settings.Boolean({
				title: LOCALIZATION\get('button_label_enabled', 'Enabled')
				tooltip: LOCALIZATION\get('setting_battlenet_enabled_description', 'If enabled, then games installed via the Blizzard Battle.net client will be included.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleBattlenetEnabled()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getBattlenetEnabled()
			})
			Settings.FolderPathSpinner({
				title: LOCALIZATION\get('setting_battlenet_paths_title', 'Paths')
				tooltip: LOCALIZATION\get('setting_battlenet_paths_description', '""Define the absolute paths to folders, which contain Blizzard Battle.net games in their own subfolders:\nIf e.g. Hearthstone is installed in "D:\\Blizzard games\\Hearthstone", then the path that you give should be "D:\\Blizzard games".\nEdit a path and input an empty string to remove that path.""')
				index: 1
				getValues: () =>
					values = [path for path in *state.paths]
					table.insert(values, LOCALIZATION\get('setting_battlenet_add_path', 'Add path...'))
					return values
				setValues: (values) =>
					@values = values
					@setIndex(@index)
				setPath: (index, path) =>
					COMPONENTS.SETTINGS\setBattlenetPath(index, path)
					@setValues(COMPONENTS.SETTINGS\getBattlenetPaths())
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_starting_bangs', 'Starting bangs')
				tooltip: LOCALIZATION\get('setting_battlenet_starting_bangs_description', 'These Rainmeter bangs are executed just before any Blizzard Battle.net game launches.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getBattlenetStartingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedBattlenetStartingBangs')
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_stopping_bangs', 'Stopping bangs')
				tooltip: LOCALIZATION\get('setting_battlenet_stopping_bangs_description', 'These Rainmeter bangs are executed just after any Blizzard Battle.net game terminates.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getBattlenetStoppingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedBattlenetStoppingBangs')
			})
		}

return Battlenet
