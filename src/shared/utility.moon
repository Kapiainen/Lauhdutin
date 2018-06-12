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
}
