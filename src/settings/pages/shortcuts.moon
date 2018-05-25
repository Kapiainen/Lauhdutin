utility = require('shared.utility')
Page = require('settings.pages.page')
Settings = require('settings.types')

class Shortcuts extends Page
	new: () =>
		super()
		@title = LOCALIZATION\get('setting_shortcuts_title', 'Windows shortcuts')
		@settings = {
			Settings.Boolean({
				title: LOCALIZATION\get('button_label_enabled', 'Enabled')
				tooltip: LOCALIZATION\get('setting_shortcuts_enabled_description', 'If enabled, then Windows shortcuts placed in the designated folder will be included.')
				toggle: () =>
					COMPONENTS.SETTINGS\toggleShortcutsEnabled()
					return true
				getState: () =>
					return COMPONENTS.SETTINGS\getShortcutsEnabled()
			})
			Settings.Action({
				title: LOCALIZATION\get('setting_shortcuts_open_folder_title', 'Folder')
				tooltip: LOCALIZATION\get('setting_shortcuts_open_folder_description', 'Shortcuts and their banners should be placed in this folder. The banners should be named after their corresponding shortcut.')
				label: LOCALIZATION\get('button_label_open', 'Open')
				perform:() =>
					SKIN\Bang(('[%s]')\format(io.joinPaths(STATE.PATHS.RESOURCES, 'Shortcuts\\')))
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_starting_bangs', 'Starting bangs')
				tooltip: LOCALIZATION\get('setting_shortcuts_starting_bangs_description', 'These Rainmeter bangs are executed just before any Windows shortcut game launches.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getShortcutsStartingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedShortcutsStartingBangs')
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_stopping_bangs', 'Stopping bangs')
				tooltip: LOCALIZATION\get('setting_shortcuts_stopping_bangs_description', 'These Rainmeter bangs are executed just after any Windows shortcut game terminates.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getShortcutsStoppingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedShortcutsStoppingBangs')
			})
		}

return Shortcuts
