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

-- May have to look into selective loading of lookup tables for various character sets.
lookup = {
	[195]: {
		[96]: {' ', '\160'}
		[97]: {'¡', '\161'}
		[98]: {'¢', '\162'}
		[99]: {'£', '\163'}
		[100]: {'¤', '\164'}
		[101]: {'¥', '\165'}
		[102]: {'¦', '\166'}
		[103]: {'§', '\167'}
		[104]: {'¨', '\168'}
		[105]: {'©', '\169'}
		[106]: {'ª', '\170'}
		[107]: {'«', '\171'}
		[108]: {'¬', '\172'}
		[110]: {'®', '\174'}
		[111]: {'¯', '\175'}
		[112]: {'°', '\176'}
		[113]: {'±', '\177'}
		[114]: {'²', '\178'}
		[115]: {'³', '\179'}
		[116]: {'´', '\180'}
		[117]: {'µ', '\181'}
		[118]: {'¶', '\182'}
		[119]: {'·', '\183'}
		[120]: {'¸', '\184'}
		[121]: {'¹', '\185'}
		[122]: {'º', '\186'}
		[123]: {'»', '\187'}
		[124]: {'¼', '\188'}
		[125]: {'½', '\189'}
		[126]: {'¾', '\190'}
		[127]: {'¿', '\191'}
		[128]: {'À', '\192'}
		[129]: {'Á', '\193'}
		[130]: {'Â', '\194'}
		[131]: {'Ã', '\195'}
		[132]: {'Ä', '\196'}
		[133]: {'Å', '\197'}
		[134]: {'Æ', '\198'}
		[135]: {'Ç', '\199'}
		[136]: {'È', '\200'}
		[137]: {'É', '\201'}
		[138]: {'Ê', '\202'}
		[139]: {'Ë', '\203'}
		[140]: {'Ì', '\204'}
		[141]: {'Í', '\205'}
		[142]: {'Î', '\206'}
		[143]: {'Ï', '\207'}
		[144]: {'Ð', '\208'}
		[145]: {'Ñ', '\209'}
		[146]: {'Ò', '\210'}
		[147]: {'Ó', '\211'}
		[148]: {'Ô', '\212'}
		[149]: {'Õ', '\213'}
		[150]: {'Ö', '\214'}
		[151]: {'×', '\215'}
		[152]: {'Ø', '\216'}
		[153]: {'Ù', '\217'}
		[154]: {'Ú', '\218'}
		[155]: {'Û', '\219'}
		[156]: {'Ü', '\220'}
		[157]: {'Ý', '\221'}
		[158]: {'Þ', '\222'}
		[159]: {'ß', '\223'}
		[160]: {'à', '\224'}
		[161]: {'á', '\225'}
		[162]: {'â', '\226'}
		[163]: {'ã', '\227'}
		[164]: {'ä', '\228'}
		[165]: {'å', '\229'}
		[166]: {'æ', '\230'}
		[167]: {'ç', '\231'}
		[168]: {'è', '\232'}
		[169]: {'é', '\233'}
		[170]: {'ê', '\234'}
		[171]: {'ë', '\235'}
		[172]: {'ì', '\236'}
		[173]: {'í', '\237'}
		[174]: {'î', '\238'}
		[175]: {'ï', '\239'}
		[176]: {'ð', '\240'}
		[177]: {'ñ', '\241'}
		[178]: {'ò', '\242'}
		[179]: {'ó', '\243'}
		[180]: {'ô', '\244'}
		[181]: {'õ', '\245'}
		[182]: {'ö', '\246'}
		[183]: {'÷', '\247'}
		[184]: {'ø', '\248'}
		[185]: {'ù', '\249'}
		[186]: {'ú', '\250'}
		[187]: {'û', '\251'}
		[188]: {'ü', '\252'}
		[189]: {'ý', '\253'}
		[190]: {'þ', '\254'}
		[191]: {'ÿ', '\255'}
	}
}

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

	waitCommand: 'ping -n 2 127.0.0.1 > nul'

	parseVDF: (file) ->
		switch type(file)
			when 'string'
				return parseVDF(file\splitIntoLines())
			when 'table'
				return parseVDF(file)
			else
				assert(nil, ('"parseVDF" does not support the "%s" type as its argument.')\format(type(file)))

	replaceUnsupportedChars: (str) ->
		assert(type(str) == 'string', 'shared.utility.replaceUnsupportedChars')
		result = ''
		charsToReplace = {}
		hasCharsToDrop = false
		hasCharsToReplace = false
		for char in str\gmatch('[%z\1-\127\194-\255][\128-\191]*')
			lookupValue = nil
			-- TODO: Have a look at this again. Seems like this would cause an excessive amount of allocations.
			-- TODO: Any way to reduce the amount of allocations?
			bytes = {char\byte(1, -1)}
			if #bytes > 1
				lookupValue = lookup
				for byte in *bytes
					continue if lookupValue == nil
					lookupValue = lookupValue[byte]
				--assert(lookupValue ~= nil,
				--	('Encountered unsupported variable-width character: %s %s')\format(char, table.concat(bytes, '|'))
				--) -- Leave here for testing purposes, but comment out for releases
				if lookupValue == nil
					hasCharsToDrop = true
					continue
				charsToReplace[lookupValue[1]] = lookupValue[2]
				hasCharsToReplace = true
			result ..= char
		if hasCharsToReplace
			for find, replace in pairs(charsToReplace)
				result = result\gsub(find, replace)
		elseif not hasCharsToDrop or #result == 0
			result = str
		return result

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
