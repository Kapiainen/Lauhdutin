utility = require('shared.utility')

migrators = {
	{
		version: 1 -- Version 2.7.1 -> 3.0.0
		func: (settings) ->
			settings.bangs = {
				global: {
					starting: {}
					stopping: {}
				}
			}
			settings.skin = {}
			settings.slots = {}
			settings.layout = {}
			settings.platforms = {
				shortcuts: {
					bangs: {
						starting: {}
						stopping: {}
					}
				}
				steam: {
					bangs: {
						starting: {}
						stopping: {}
					}
				}
				battlenet: {
					bangs: {
						starting: {}
						stopping: {}
					}
					paths: {}
				}
				gogGalaxy: {
					bangs: {
						starting: {}
						stopping: {}
					}
				}
			}
			settings.layout.horizontal = settings.orientation == 'horizontal'
			if settings.layout.horizontal
				settings.layout.rows = settings.slot_rows_columns
				settings.layout.columns = settings.slot_count_per_row_column
			else
				settings.layout.rows = settings.slot_count_per_row_column
				settings.layout.columns = settings.slot_rows_columns
			settings.orientation = nil
			settings.slot_count_per_row_column = nil
			settings.slot_rows_columns = nil

			settings.slots.clickAnimation = switch settings.click_animation
				when 0 then ENUMS.SLOT_CLICK_ANIMATIONS.NONE
				when 1 then ENUMS.SLOT_CLICK_ANIMATIONS.SHRINK
				when 2 then ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_LEFT
				when 3 then ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_RIGHT
				when 4 then ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_UP
				when 5 then ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_DOWN
			settings.click_animation = nil
			
			settings.slots.hoverAnimation = switch settings.hover_animation
				when 0 then ENUMS.SLOT_HOVER_ANIMATIONS.NONE
				when 1 then ENUMS.SLOT_HOVER_ANIMATIONS.ZOOM_IN
				when 2 then ENUMS.SLOT_HOVER_ANIMATIONS.JIGGLE
				when 3 then ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_LEFT_RIGHT
			if settings.slots.hoverAnimation == ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_LEFT_RIGHT and not settings.layout.horizontal
				settings.slots.hoverAnimation = ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_UP_DOWN
			settings.hover_animation = nil

			settings.skin.skinAnimation = switch settings.skin_slide_animation_direction
				when 0 then ENUMS.SKIN_ANIMATIONS.NONE
				when 1 then ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT
				when 2 then ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT
				when 3 then ENUMS.SKIN_ANIMATIONS.SLIDE_UP
				when 4 then ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN
			settings.skin_slide_animation_direction = nil

			settings.slots.overlayEnabled = settings.slot_highlight
			settings.slot_highlight = nil

			settings.sorting = switch settings.sortstate
				when 0 then ENUMS.SORTING_TYPES.ALPHABETICALLY
				when 1 then ENUMS.SORTING_TYPES.LAST_PLAYED
				when 2 then ENUMS.SORTING_TYPES.HOURS_PLAYED
				else ENUMS.SORTING_TYPES.ALPHABETICALLY
			settings.sortstate = nil

			settings.layout.toolbarAtTop = settings.toolbar_position == 0
			settings.toolbar_position = nil
			
			for bang in *settings.start_game_bang\split('%[!')
				table.insert(settings.bangs.global.starting, '[!' .. bang)
			settings.start_game_bang = nil
			
			for bang in *settings.stop_game_bang\split('%[!')
				table.insert(settings.bangs.global.stopping, '[!' .. bang)
			settings.stop_game_bang = nil
			
			settings.layout.width = settings.slot_width
			settings.slot_width = nil

			settings.layout.height = settings.slot_height
			settings.slot_height = nil

			settings.platforms.steam.path = settings.steam_path
			settings.steam_path = nil

			settings.platforms.steam.communityID = settings.steam_id64
			settings.steam_id64 = nil

			settings.platforms.steam.accountID = settings.steam_userdataid
			settings.steam_userdataid = nil

			settings.platforms.steam.useCommunityProfile = settings.parse_steam_community_profile
			settings.parse_steam_community_profile = nil

			for path in *settings.battlenet_path\split('|')
				table.insert(settings.platforms.battlenet.paths, path)
			settings.battlenet_path = nil

			settings.platforms.gogGalaxy.programDataPath = settings.galaxy_path
			settings.galaxy_path = nil

			settings.show_hours_played = nil
			settings.show_platform_running = nil
			settings.slot_background_color = nil
			settings.slot_text_color = nil
			settings.adjust_zpos = nil
			settings.execute_bangs_by_default = nil
			settings.fuzzy_search = nil
			settings.hidden_games = nil
			settings.installed_games = nil
			settings.set_games_to_execute_bangs = nil
			settings.python_path = nil
			settings.steam_personaname = nil
			settings.show_platform = nil
	}
}

class Settings
	new: () =>
		@version = 1
		@path = 'settings.json'
		@defaultSettings = {
			numberOfBackups: 5
			logging: false -- If true, then extra information is printed to Rainmeter's log. Useful when troubleshooting issues.
			sorting: ENUMS.SORTING_TYPES.ALPHABETICALLY -- How games are sorted.
			bangs: {
				enabled: true -- Whether or not bangs are executed (applies to global, platform-specific, and game-specific bangs).
				global: {
					starting: {} -- Bangs that are executed by ALL games when a game is launched.
					stopping: {} -- Bangs that are executed by ALL games when a game terminates.
				}
			}
			layout: {
				rows: 1 -- The number of rows of slots.
				columns: 4 -- The number of columns of slots.
				width: 320 -- The width of slots in pixels.
				height: 150 -- The height of slots in pixels.
				horizontal: true -- The orientation of the skin. True places slots from left-to-right and top-to-bottom. False places slots from top-to-bottom and left-to-right.
				toolbarAtTop: true -- If true, then the toolbar is at the top of the skin. If false, then the toolbar is at the bottom of the skin.
				centerOnMonitor: true -- If true, then certain windows are centered on the monitor that the main skin is on.
			}
			skin: {
				hideWhilePlaying: true -- Whether or not the skin is hidden and revealed when a game is launched and terminated, respectively.
				skinAnimation: ENUMS.SKIN_ANIMATIONS.NONE -- The skin animation that plays when the skin is revealed or hidden when the mouse hovers over or leaves the skin.
				revealingDelay: 0 -- The duration (in milliseconds) between the mouse hovering over the skin's enabler edge and the skin revealing animation starting.
				scrollStep: 1 -- The number of games that are scrolled on each scroll event.
			}
			slots: {
				doubleClickToLaunch: false
				overlayEnabled: true
				hoverAnimation: ENUMS.SLOT_HOVER_ANIMATIONS.ZOOM_IN
				clickAnimation: ENUMS.SLOT_CLICK_ANIMATIONS.SHRINK
			}
			platforms: {
				shortcuts: { -- Windows shortcuts (.lnk or .url files).
					enabled: false
					bangs: {
						starting: {} -- Bangs that are executed by all Windows shortcut games when a game is launched.
						stopping: {} -- Bangs that are executed by all Windows shortcut games when a game terminates.
					}
				}
				steam: { -- Steam games associated with a particular account.
					enabled: false
					bangs: {
						starting: {} -- Bangs that are executed by all Stean games when a game is launched.
						stopping: {} -- Bangs that are executed by all Steam games when a game terminates.
					}
					path: '' -- The absolute path to the folder that contains the Steam executable.
					accountID: '' -- The partial SteamID3 (UserDataID) associated with the chosen account. This is also the name of the subfolder in "\Steam\userdata" and is used to read files relevant to the chosen account.
					communityID: '' -- The SteamID64 associated with the chosen account. Used to download the Steam community profile, which must be public, of the chosen account.
					useCommunityProfile: false -- If true, then the Steam community profile associated with the chosen account will be downloaded and parsed to get additional information (all games associated with the account, hours played, etc.) not available via local files.
				}
				battlenet: { -- Blizzard Battle.net games installed in specific folders.
					enabled: false
					bangs: {
						starting: {} -- Bangs that are executed by all Blizzard Battle.net games when a game is launched.
						stopping: {} -- Bangs that are executed by all Blizzard Battle.net games when a game terminates.
					}
					paths: {} -- The absolute paths to folders, which in turn contain games in their own subfolders (e.g. "D:\Blizzard games" if Hearthstone is installed in "D:\Blizzard games\Hearthstone").
				}
				gogGalaxy: { -- GOG games installed via the GOG Galaxy client.
					enabled: false
					bangs: {
						starting: {} -- Bangs that are executed by all GOG Galaxy games when a game is launched.
						stopping: {} -- Bangs that are executed by all GOG Galaxy games when a game terminates.
					}
					clientPath: '' -- The absolute path to the folder containing the GOG Galaxy executable. Needed only if games are launched via the GOG Galaxy client rather than directly via a game's executable.
					programDataPath: 'C:\\ProgramData\\GOG.com\\Galaxy' -- The absolute path to the ProgramData folder (usually "C:\ProgramData\GOG.com\Galaxy"), which contains some of the local files that are used to figure out which games are installed.
					indirectLaunch: false -- If true, then games are launched via the GOG Galaxy client, which enables the use of the GOG Galaxy overlay and tracking time played in the GOG Galaxy client. If false, then games are launched directly via their executables.
				}
			}
		}
		@settings = @load()

	get: () => return @settings

	load: () =>
		if io.fileExists(@path)
			settings = io.readJSON(@path)
			version = settings.version or 0
			settings = settings.settings if version > 0
			if @migrate(settings, version)
				@save(settings)
			return settings
		@save(@defaultSettings)
		return @defaultSettings

	reset: () =>
		@save(@defaultSettings)
		@settings = io.readJSON(@path)

	save: (settings = @settings) => io.writeJSON(@path, {
		version: @version
		settings: settings
	})

	migrate: (settings, version) =>
		assert(type(version) == 'number' and version % 1 == 0, 'Expected the settings version number to be an integer.')
		assert(version <= @version, ('Unsupported settings version. Expected version %d or earlier.')\format(@version))
		return false if version == @version
		for migrator in *migrators
			if version < migrator.version
				migrator.func(settings)
		addDefaults = (defaults, loaded) ->
			for key, value in pairs(defaults)
				if loaded[key] == nil
					loaded[key] = value
				else
					if type(value) == 'table' and type(loaded[key]) == 'table'
						addDefaults(value, loaded[key])
		addDefaults(@defaultSettings, settings)
		return true

	hasChanged: (oldSettingsTable) =>
		check = (new, old) ->
			return true if old == nil
			for key, value in pairs(new)
				if type(value) == 'table'
					if check(value, old[key])
						return true
				else
					if value ~= old[key]
						return true
			return false
		return check(@settings, oldSettingsTable)

	getNumberOfBackups: () => return @settings.numberOfBackups or 5

	setNumberOfBackups: (value) =>
		return if value < 0
		@settings.numberOfBackups = value

	getLogging: () =>
		if @settings.logging ~= nil
			return @settings.logging
		return false

	toggleLogging: () => @settings.logging = not @settings.logging

	getSorting: () => return @settings.sorting or ENUMS.SORTING_TYPES.ALPHABETICALLY

	setSorting: (value) =>
		return if value < 1
		@settings.sorting = value

	getLocalization: () => return @settings.localization or 'English'

	setLocalization: (str) => @settings.localization = str

	-- Bangs
	getBangsEnabled: () =>
		if @settings.bangs.enabled ~= nil
			return @settings.bangs.enabled
		return false
	
	toggleBangsEnabled: () => @settings.bangs.enabled = not @settings.bangs.enabled

	getGlobalStartingBangs: () => return @settings.bangs.global.starting or {}

	setGlobalStartingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.bangs.global.starting = bangs

	getGlobalStoppingBangs: () => return @settings.bangs.global.stopping or {}

	setGlobalStoppingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.bangs.global.stopping = bangs

	-- Layout
	getLayoutRows: () => return @settings.layout.rows or 1

	setLayoutRows: (value) =>
		return if value < 1
		@settings.layout.rows = value

	getLayoutColumns: () => return @settings.layout.columns or 6

	setLayoutColumns: (value) =>
		return if value < 1
		@settings.layout.columns = value

	getLayoutWidth: () => return @settings.layout.width or 320

	setLayoutWidth: (value) =>
		return if value < 16
		@settings.layout.width = value

	getLayoutHeight: () => return @settings.layout.height or 150

	setLayoutHeight: (value) =>
		return if value < 16
		@settings.layout.height = value

	getLayoutHorizontal: () =>
		if @settings.layout.horizontal ~= nil
			return @settings.layout.horizontal
		return true

	toggleLayoutHorizontal: () => @settings.layout.horizontal = not @settings.layout.horizontal

	getLayoutToolbarAtTop: () =>
		if @settings.layout.toolbarAtTop ~= nil
			return @settings.layout.toolbarAtTop
		return true

	toggleLayoutToolbarAtTop: () => @settings.layout.toolbarAtTop = not @settings.layout.toolbarAtTop

	getCenterOnMonitor: () => 
		if @settings.layout.centerOnMonitor ~= nil
			return @settings.layout.centerOnMonitor
		return true

	toggleCenterOnMonitor: () => @settings.layout.centerOnMonitor = not @settings.layout.centerOnMonitor

	-- Skin
	getHideSkin: () =>
		if @settings.skin.hideWhilePlaying ~= nil
			return @settings.skin.hideWhilePlaying
		return false

	toggleHideSkin: () => @settings.skin.hideWhilePlaying = not @settings.skin.hideWhilePlaying

	getSkinSlideAnimation: () => return @settings.skin.skinAnimation or ENUMS.SKIN_ANIMATIONS.NONE

	setSkinSlideAnimation: (value) =>
		return if value < ENUMS.SKIN_ANIMATIONS.NONE or value >= ENUMS.SKIN_ANIMATIONS.MAX
		@settings.skin.skinAnimation = value

	getSkinRevealingDelay: () => return @settings.skin.revealingDelay or 500

	setSkinRevealingDelay: (value) =>
		return if value < 0
		@settings.skin.revealingDelay = value

	getScrollStep: () => return @settings.skin.scrollStep or 1

	setScrollStep: (value) =>
		return if value < 1
		@settings.skin.scrollStep = value

	-- Slots
	getDoubleClickToLaunch: () =>
		if @settings.slots.doubleClickToLaunch ~= nil
			return @settings.slots.doubleClickToLaunch
		return false

	toggleDoubleClickToLaunch: () => @settings.slots.doubleClickToLaunch = not @settings.slots.doubleClickToLaunch

	getSlotsOverlayEnabled: () =>
		if @settings.slots.overlayEnabled ~= nil
			return @settings.slots.overlayEnabled
		return true

	toggleSlotsOverlayEnabled: () => @settings.slots.overlayEnabled = not @settings.slots.overlayEnabled

	getSlotsHoverAnimation: () => return @settings.slots.hoverAnimation or ENUMS.SLOT_HOVER_ANIMATIONS.ZOOM_IN
	
	setSlotsHoverAnimation: (value) =>
		return if value < ENUMS.SLOT_HOVER_ANIMATIONS.NONE or value >= ENUMS.SLOT_HOVER_ANIMATIONS.MAX
		@settings.slots.hoverAnimation = value

	getSlotsClickAnimation: () => return @settings.slots.clickAnimation or ENUMS.SLOT_CLICK_ANIMATIONS.SHRINK

	setSlotsClickAnimation: (value) =>
		return if value < ENUMS.SLOT_CLICK_ANIMATIONS.NONE or value >= ENUMS.SLOT_CLICK_ANIMATIONS.MAX
		@settings.slots.clickAnimation = value

	-- Windows shortcuts
	getShortcutsEnabled: () =>
		if @settings.platforms.shortcuts.enabled ~= nil
			return @settings.platforms.shortcuts.enabled
		return false
	
	toggleShortcutsEnabled: () =>
		@settings.platforms.shortcuts.enabled = not @settings.platforms.shortcuts.enabled

	getShortcutsStartingBangs: () => return @settings.platforms.shortcuts.bangs.starting or {}
	
	setShortcutsStartingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.platforms.shortcuts.bangs.starting = bangs
	
	getShortcutsStoppingBangs: () => return @settings.platforms.shortcuts.bangs.stopping or {}
	
	setShortcutsStoppingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.platforms.shortcuts.bangs.stopping = bangs

	-- Steam
	getSteamEnabled: () =>
		if @settings.platforms.steam.enabled ~= nil
			return @settings.platforms.steam.enabled
		return false

	toggleSteamEnabled: () => @settings.platforms.steam.enabled = not @settings.platforms.steam.enabled

	getSteamPath: () => return @settings.platforms.steam.path or nil
	
	setSteamPath: (path) =>
		return false unless io.fileExists(io.joinPaths(path, 'Steam.exe'), false)
		@settings.platforms.steam.path = path
		SKIN\Bang(('["#@#windowless.vbs" "#@#settings\\platforms\\steam\\listUsers.bat" "%s"]')\format(io.joinPaths(path, 'userdata')))
		utility.runCommand(utility.waitCommand, '', 'OnSteamUsersListed')
		return true

	getSteamAccountID: () => return @settings.platforms.steam.accountID or nil
	
	setSteamAccountID: (value) => @settings.platforms.steam.accountID = value
	
	getSteamCommunityID: () => return @settings.platforms.steam.communityID or nil
	
	setSteamCommunityID: (value) => @settings.platforms.steam.communityID = value

	getSteamParseCommunityProfile: () =>
		if @settings.platforms.steam.useCommunityProfile ~= nil
			return @settings.platforms.steam.useCommunityProfile
		return false

	toggleSteamParseCommunityProfile: () =>
		@settings.platforms.steam.useCommunityProfile = not @settings.platforms.steam.useCommunityProfile

	getSteamStartingBangs: () => return @settings.platforms.steam.bangs.starting or {}
	
	setSteamStartingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.platforms.steam.bangs.starting = bangs
	
	getSteamStoppingBangs: () => return @settings.platforms.steam.bangs.stopping or {}
	
	setSteamStoppingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.platforms.steam.bangs.stopping = bangs

	-- Blizzard Battle.net
	getBattlenetEnabled: () => return @settings.platforms.battlenet.enabled or false

	toggleBattlenetEnabled: () =>
		@settings.platforms.battlenet.enabled = not @settings.platforms.battlenet.enabled

	getBattlenetPaths: () => return @settings.platforms.battlenet.paths or {}

	setBattlenetPath: (index, path) =>
		if path == ''
			table.remove(@settings.platforms.battlenet.paths, index)
		else
			@settings.platforms.battlenet.paths[index] = path

	getBattlenetStartingBangs: () => return @settings.platforms.battlenet.bangs.starting or {}

	setBattlenetStartingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.platforms.battlenet.bangs.starting = bangs

	getBattlenetStoppingBangs: () => return @settings.platforms.battlenet.bangs.stopping or {}

	setBattlenetStoppingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.platforms.battlenet.bangs.stopping = bangs

	-- GOG Galaxy
	getGOGGalaxyEnabled: () => return @settings.platforms.gogGalaxy.enabled or false
	
	toggleGOGGalaxyEnabled: () =>
		@settings.platforms.gogGalaxy.enabled = not @settings.platforms.gogGalaxy.enabled

	getGOGGalaxyClientPath: () => return @settings.platforms.gogGalaxy.clientPath or nil
	
	setGOGGalaxyClientPath: (path) =>
		return false unless io.fileExists(io.joinPaths(path, 'GalaxyClient.exe'), false)
		@settings.platforms.gogGalaxy.clientPath = path
		return true
	
	getGOGGalaxyProgramDataPath: () => return @settings.platforms.gogGalaxy.programDataPath or nil

	setGOGGalaxyProgramDataPath: (path) =>
		return false unless io.fileExists(io.joinPaths(path, 'storage\\index.db'), false)
		@settings.platforms.gogGalaxy.programDataPath = path
		return true

	getGOGGalaxyIndirectLaunch: () => return @settings.platforms.gogGalaxy.indirectLaunch or false

	toggleGOGGalaxyIndirectLaunch: () => @settings.platforms.gogGalaxy.indirectLaunch = not @settings.platforms.gogGalaxy.indirectLaunch

	getGOGGalaxyStartingBangs: () => return @settings.platforms.gogGalaxy.bangs.starting or {}

	setGOGGalaxyStartingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.platforms.gogGalaxy.bangs.starting = bangs

	getGOGGalaxyStoppingBangs: () => return @settings.platforms.gogGalaxy.bangs.stopping or {}

	setGOGGalaxyStoppingBangs: (tbl) =>
		bangs = {}
		for bang in *tbl
			bang = bang\trim()
			table.insert(bangs, bang) if bang ~= ''
		@settings.platforms.gogGalaxy.bangs.stopping = bangs

return Settings
