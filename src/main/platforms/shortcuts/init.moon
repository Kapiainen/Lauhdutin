Platform = require('main.platforms.platform')
Game = require('main.game')

-- Dump a list of .lnk and .url files along with their target and argument properties.

class Shortcuts extends Platform
	new: (settings) =>
		super(settings)
		@platformID = ENUMS.PLATFORM_IDS.SHORTCUTS
		@name = LOCALIZATION\get('platform_name_windows_shortcut', 'Windows shortcut')
		@cachePath = 'cache\\shortcuts\\'
		@shortcutsPath = io.joinPaths(STATE.PATHS.RESOURCES, 'Shortcuts\\')
		@outputPath = io.joinPaths(@cachePath, 'output.txt')
		@enabled = settings\getShortcutsEnabled()

	validate: () => return

	parseShortcuts: () =>
		if io.fileExists(@outputPath)
			io.writeFile(@outputPath, '')
		SKIN\Bang(('["#@#windowless.vbs" "#@#main\\platforms\\shortcuts\\parseShortcuts.bat" "%s"]')\format(@shortcutsPath))
		return @getWaitCommand(), '', 'OnParsedShortcuts'

	hasParsedShortcuts: () => return io.fileExists(io.joinPaths(@cachePath, 'completed.txt'))

	getOutputPath: () => return @outputPath

	generateGames: (output) =>
		assert(type(output) == 'string')
		if output == ''
			@games = {}
			return
		games = {}
		lines = output\splitIntoLines()
		while #lines > 0 and #lines % 3 == 0
			absoluteFilePath = table.remove(lines, 1)
			relativeFilePath = absoluteFilePath\sub(#@shortcutsPath + 1)
			parts = relativeFilePath\split('\\')
			title = switch #parts
				when 1 then parts[1]
				when 2 then parts[2]
				else assert(nil, 'Unexpected path structure when processing Windows shortcuts.')
			title = title\match('^([^%.]+)')
			platformOverride = switch #parts
				when 2 then parts[1]
				else nil
			banner = nil
			expectedBanner = nil
			if platformOverride ~= nil
				banner = @getBannerPath(title, ('Shortcuts\\%s')\format(platformOverride))
			else
				banner = @getBannerPath(title, 'Shortcuts')
			unless banner
				expectedBanner = title
			path = table.remove(lines, 1)\match('^	Target=(.-)$')
			uninstalled = nil
			unless io.fileExists(path, false)
				uninstalled = true
			path = ('"%s"')\format(path)
			arguments = table.remove(lines, 1)
			arguments = arguments\match('^	Arguments=(.-)$') if arguments
			arguments = arguments\trim() if arguments
			if arguments ~= nil and arguments ~= ''
				args = {}
				attempts = 20
				while #arguments > 0 and attempts > 0
					arg = nil
					if arguments\match('^"') -- Arguments inside quotation marks
						starts, ends = arguments\find('"(.-)"')
						arg = arguments\sub(starts + 1, ends - 1)
						arguments = arguments\sub(ends + 1)\trim()
					else -- Single word arguments
						starts, ends = arguments\find('([^%s]+)')
						arg = arguments\sub(starts, ends)
						arguments = arguments\sub(ends + 1)\trim()
					if arg == nil
						attempts -= 1
					else
						table.insert(args, arg)
				arguments = args
				if #arguments > 0
					path = ('%s "%s"')\format(path, table.concat(arguments, '" "'))
			if title == nil
				log('Skipping Windows shortcut', absoluteFilePath, 'because title could not be found')
				continue
			elseif path == nil
				log('Skipping Windows shortcut', absoluteFilePath, 'because path could not be found')
				continue
			table.insert(games, {
				:title
				:banner
				:expectedBanner
				:path
				:platformOverride
				:uninstalled
				platformID: @platformID
			})
		@games = [Game(args) for args in *games]

if RUN_TESTS
	assertionMessage = 'Windows shortcuts test failed!'
	settings = {
		getShortcutsEnabled: () => return true
	}
	shortcuts = Shortcuts(settings)
	output = 'D:\\Programs\\Rainmeter\\Skins\\Lauhdutin\\@Resources\\Shortcuts\\Some game.lnk
	Target=Y:\\Games\\Some game\\game.exe
	Arguments=
D:\\Programs\\Rainmeter\\Skins\\Lauhdutin\\@Resources\\Shortcuts\\Some platform\\Some other game.lnk
	Target=Y:\\Games\\Some other game\\othergame.exe
	Arguments=--console'
	shortcuts\generateGames(output)
	games = shortcuts.games
	assert(#games == 2)
	assert(games[1].title == 'Some game', assertionMessage)
	assert(games[1].path == '"Y:\\Games\\Some game\\game.exe"', assertionMessage)
	assert(games[1].platformID == ENUMS.PLATFORM_IDS.SHORTCUTS, assertionMessage)
	assert(games[1].process == 'game.exe', assertionMessage)
	assert(games[1].uninstalled == true, assertionMessage)
	assert(games[1].expectedBanner == 'Some game', assertionMessage)
	assert(games[2].title == 'Some other game', assertionMessage)
	assert(games[2].path == '"Y:\\Games\\Some other game\\othergame.exe" "--console"', assertionMessage)
	assert(games[2].platformID == ENUMS.PLATFORM_IDS.SHORTCUTS, assertionMessage)
	assert(games[2].platformOverride == 'Some platform', assertionMessage)
	assert(games[2].process == 'othergame.exe', assertionMessage)
	assert(games[2].uninstalled == true, assertionMessage)
	assert(games[2].expectedBanner == 'Some other game', assertionMessage)

return Shortcuts
