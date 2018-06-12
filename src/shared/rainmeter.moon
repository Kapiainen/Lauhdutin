class Config
	new: (str) =>
		assert(type(str) == 'string' and str ~= '', 'shared.config.Config')
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

export RAINMETER = {}
rainmeterINIPath = io.joinPaths(SKIN\GetVariable('SETTINGSPATH'), 'Rainmeter.ini')

RAINMETER.GetConfig = (name) =>
	assert(type(name) == 'string', 'shared.skin.GetConfig')
	rainmeterINI = io.readFile(rainmeterINIPath, false)
	pattern = '%[' .. name .. '%][^%[]+'
	starts, ends = rainmeterINI\find(pattern)
	return nil if starts == nil or ends == nil
	return Config(rainmeterINI\sub(starts, ends))

RAINMETER.GetConfigs = (names) =>
	rainmeterINI = io.readFile(rainmeterINIPath, false)
	configs = {}
	for name in *names
		pattern = '%[' .. name .. '%][^%[]+'
		starts, ends = rainmeterINI\find(pattern)
		continue if starts == nil or ends == nil
		table.insert(configs, Config(rainmeterINI\sub(starts, ends)))
	return configs

RAINMETER.GetConfigMonitor = (config) =>
	assert(config.__class == Config, 'shared.skin.GetConfigMonitor')
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

RAINMETER.CenterOnMonitor = (configWidth, configHeight, screen = 1) =>
	assert(type(configWidth) == 'number', 'shared.skin.CenterOnMonitor')
	assert(type(configHeight) == 'number', 'shared.skin.CenterOnMonitor')
	assert(type(screen) == 'number', 'shared.skin.CenterOnMonitor')
	monitorX = tonumber(SKIN\GetVariable(('SCREENAREAX@%d')\format(screen)))
	monitorY = tonumber(SKIN\GetVariable(('SCREENAREAY@%d')\format(screen)))
	monitorWidth = tonumber(SKIN\GetVariable(('SCREENAREAWIDTH@%d')\format(screen)))
	monitorHeight = tonumber(SKIN\GetVariable(('SCREENAREAHEIGHT@%d')\format(screen)))
	x = math.round(monitorX + (monitorWidth - configWidth) / 2)
	y = math.round(monitorY + (monitorHeight - configHeight) / 2)
	SKIN\Bang(('[!Move "%d" "%d"]')\format(x, y))
