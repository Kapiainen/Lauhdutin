class Config
	new: (str) =>
		assert(type(str) == 'string' and str ~= '', 'shared.utility.Config')
		@active = tonumber(str\match('Active=(%d+)')) or 0
		@windowX = tonumber(str\match('WindowX=(%d+)')) or 0
		@windowY = tonumber(str\match('WindowY=(%d+)')) or 0
		@clickThrough = tonumber(str\match('ClickThrough=(%d+)')) or 0
		@draggable = tonumber(str\match('Draggable=(%d+)')) or 0
		@snapEdges = tonumber(str\match('SnapEdges=(%d+)')) or 0
		@keepOnScreen = tonumber(str\match('KeepOnScreen=(%d+)')) or 0
		@alwaysOnTop = tonumber(str\match('AlwaysOnTop=(%d+)')) or 0
		@loadOrder = tonumber(str\match('LoadOrder=(%d+)')) or 0

	isActive: () => return @active == 1
	getX: () => return @windowX
	getY: () => return @windowY
	getZ: () => return @alwaysOnTop
	isClickThrough: () => return @clickThrough == 1
	isDraggable: () => return @draggable == 1
	snapsToEdges: () => return @snapEdges == 1
	isKeptOnScreen: () => return @keepOnScreen == 1
	getLoadOrder: () => return @loadOrder

parseVDF = (lines, start = 1) ->
	result = {}
	i = start - 1
	while i < #lines
		i += 1
		key = lines[i]\match('^%s*"([^"]+)"%s*$') -- Start of a dictionary
		if key ~= nil
			assert(lines[i + 1]\match('^%s*{%s*$') ~= nil, '"parseVDF" expected "{".')
			tbl, i = parseVDF(lines, i + 2)
			result[key\lower()] = tbl
		else
			key, value = lines[i]\match('^%s*"([^"]+)"%s*"(.-)"%s*$') -- Key-value pair
			if key ~= nil and value ~= nil
				result[key\lower()] = value
			else
				if lines[i]\match('^%s*}%s*$') -- End of a dictionary
					return result, i
				elseif lines[i]\match('^%s*//.*$') -- Comment
					continue
				elseif lines[i]\match('^%s*"#base"%s*"([^"]+)"%s*$')
					continue
				else
					assert(nil, ('"parseVDF" encountered unexpected input on line %d: %s.')\format(i, lines[i]))		
	return result, i

return {
	createJSONHelpers: () ->
		json = require('lib.json')
		assert(type(json) == 'table', 'shared.utility.createJSONHelpers')
		io.readJSON = (path, pathIsRelative = true) -> return json.decode(io.readFile(path, pathIsRelative))

		io.writeJSON = (relativePath, tbl) ->
			assert(type(tbl) == 'table', 'io.writeJSON')
			return io.writeFile(relativePath, json.encode(tbl))

	runCommand: (parameter, output, callback, callbackArgs = {}, state = 'Hide', outputType = 'UTF16') ->
		assert(type(parameter) == 'string', 'shared.utility.runCommand')
		assert(type(output) == 'string', 'shared.utility.runCommand')
		assert(type(callback) == 'string', 'shared.utility.runCommand')
		SKIN\Bang(('[!SetOption "Command" "Parameter" "%s"]')\format(parameter))
		SKIN\Bang(('[!SetOption "Command" "OutputFile" "%s"]')\format(output))
		SKIN\Bang(('[!SetOption "Command" "OutputType" "%s"]')\format(outputType))
		SKIN\Bang(('[!SetOption "Command" "State" "%s"]')\format(state))
		SKIN\Bang(('[!SetOption "Command" "FinishAction" "[!CommandMeasure Script %s(%s)]"]')\format(callback, table.concat(callbackArgs, ', ')))
		SKIN\Bang('[!UpdateMeasure "Command"]')
		SKIN\Bang('[!CommandMeasure "Command" "Run"]')

	runLastCommand: () -> SKIN\Bang('[!CommandMeasure "Command" "Run"]')

	parseVDF: (file) ->
		switch type(file)
			when 'string'
				return parseVDF(file\splitIntoLines())
			when 'table'
				return parseVDF(file)
			else
				assert(nil, ('"parseVDF" does not support the "%s" type as its argument.')\format(type(file)))

	getConfig: (name) ->
		assert(type(name) == 'string', 'shared.utility.getConfig')
		path = io.joinPaths(SKIN\GetVariable('SETTINGSPATH'), 'Rainmeter.ini')
		rainmeterINI = io.readFile(path, false)
		pattern = '%[' .. name .. '%][^%[]+'
		starts, ends = rainmeterINI\find(pattern)
		return nil if starts == nil or ends == nil
		return Config(rainmeterINI\sub(starts, ends))

	getConfigs: (names) ->
		path = io.joinPaths(SKIN\GetVariable('SETTINGSPATH'), 'Rainmeter.ini')
		rainmeterINI = io.readFile(path, false)
		configs = {}
		for name in *names
			pattern = '%[' .. name .. '%][^%[]+'
			starts, ends = rainmeterINI\find(pattern)
			continue if starts == nil or ends == nil
			table.insert(configs, Config(rainmeterINI\sub(starts, ends)))
		return configs

	getConfigMonitor: (config) ->
		assert(config.__class == Config, 'shared.utility.getConfigMonitor')
		x = config\getX()
		y = config\getY()
		for i = 1, 8
			monitorX = tonumber(SKIN\GetVariable(('SCREENAREAX@%d')\format(i)))
			monitorY = tonumber(SKIN\GetVariable(('SCREENAREAY@%d')\format(i)))
			monitorWidth = tonumber(SKIN\GetVariable(('SCREENAREAWIDTH@%d')\format(i)))
			monitorHeight = tonumber(SKIN\GetVariable(('SCREENAREAHEIGHT@%d')\format(i)))
			continue if x < monitorX or x > (monitorX + monitorWidth - 1)
			continue if y < monitorY or y > (monitorY + monitorHeight - 1)
			return i
		return nil

	centerOnMonitor: (width, height, screen = 1) ->
		assert(type(width) == 'number', 'shared.utility.centerOnMonitor')
		assert(type(height) == 'number', 'shared.utility.centerOnMonitor')
		assert(type(screen) == 'number', 'shared.utility.centerOnMonitor')
		monitorX = tonumber(SKIN\GetVariable(('SCREENAREAX@%d')\format(screen)))
		monitorY = tonumber(SKIN\GetVariable(('SCREENAREAY@%d')\format(screen)))
		monitorWidth = tonumber(SKIN\GetVariable(('SCREENAREAWIDTH@%d')\format(screen)))
		monitorHeight = tonumber(SKIN\GetVariable(('SCREENAREAHEIGHT@%d')\format(screen)))
		x = math.round(monitorX + (monitorWidth - width) / 2)
		y = math.round(monitorY + (monitorHeight - height) / 2)
		return x, y
}
