module_info = {
	name: 'Rainmeter helpers'
	author: 'Kapiainen'
	description: 'A module with some helper functions for scripting in the Lua environment provided by Rainmeter.'
	version: {
		major: 1
		minor: 0
		patch: 0
	}
	license: 'The MIT License

Copyright 2018 Kapiainen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.'
}

vars = {
	paths: {
		executable: SKIN\GetVariable('PROGRAMPATH') .. 'Rainmeter.exe'
		resources: SKIN\GetVariable('@')
	}
	currentConfig: SKIN\GetVariable('CURRENTCONFIG')
}

-- 'string' functions
string.startsWith = (str, prefix) ->
	assert(type(str) == 'string', '"string.startsWith" expected a string as the first argument.')
	assert(type(prefix) == 'string', '"string.startsWith" expected a string as the second argument.')
	return str\match('^(' .. prefix .. '.-)$') ~= nil

string.endsWith = (str, suffix) ->
	assert(type(str) == 'string', '"string.endsWith" expected a string as the first argument.')
	assert(type(suffix) == 'string', '"string.endsWith" expected a string as the second argument.')
	return str\match('^(.-' .. suffix .. ')$') ~= nil

string.trim = (str) ->
	assert(type(str) == 'string', '"string.trim" expected a string as the argument.')
	return str\match('^%s*(.-)%s*$')

string.split = (str, pattern) ->
	assert(type(str) == 'string', '"string.split" expected a string as the first argument.')
	assert(type(pattern) == 'string', '"string.split" expected a string as the second argument.')
	return [match for match in str\gmatch('([^' .. pattern .. ']+)')]

string.splitIntoLines = (str) ->
	assert(type(str) == 'string', '"string.splitIntoLines" expected a string as the first argument.')
	return str\split('\n\r')

string.splitIntoChars = (str) ->
	assert(type(str) == 'string', '"string.splitIntoChars" expected a string as the first argument.')
	return [char for char in str\gmatch('.')]

string.splitIntoWords = (str) ->
	assert(type(str) == 'string', '"string.splitIntoWords" expected a string as the first argument.')
	return [word for word in str\gmatch('[^%s%p]*') when word ~= nil and word ~= '']

-- 'io' functions
io.joinPaths = (...) ->
	args = {n: select('#', ...), ...}
	assert(type(args[1]) == 'string', ('"io.joinPaths" expected every argument to be a string, but argument #%d was %s.')\format(1, type(args[1])))
	path = args[1]
	for i = 2, args.n
		assert(type(args[i]) == 'string', ('"io.joinPaths" expected every argument to be a string, but argument #%d was %s.')\format(i, type(args[i])))
		unless path\endsWith('\\')
			path ..= '\\'
		path ..= args[i]
	return path

io.splitPath = (path) ->
	assert(type(path) == 'string', '"io.split" expected a string argument.')
	path = path\reverse()
	tail, head = path\match('^([^\\]+)(.*)$')
	if head ~= nil and tail ~= nil
		return head\reverse(), tail\reverse()
	return nil, nil

io.absolutePath = (relPath) ->
	assert(type(relPath) == 'string', '"io.absolutePath" expected a string argument.')
	return io.joinPaths(vars.paths.resources, relPath)

io.fileExists = (path, pathIsRelative = true) ->
	assert(type(path) == 'string', '"io.fileExists" expected a string as the first argument.')
	assert(type(pathIsRelative) == 'boolean', '"io.fileExists" expected a boolean as the second argument.')
	path = io.joinPaths(vars.paths.resources, path) if pathIsRelative
	f = io.open(path, 'r')
	if f then f\close() else return false
	return true

io.readFile = (path, pathIsRelative = true, openMode = 'r') ->
	assert(type(path) == 'string', '"io.readFile" expected a string as the first argument.')
	assert(type(pathIsRelative) == 'boolean', '"io.readFile" expected a boolean as the second argument.')
	assert((openMode\find('r')) ~= nil, '"io.readFile" expected "openMode" to contain "r".')
	path = io.joinPaths(vars.paths.resources, path) if pathIsRelative
	f = io.open(path, openMode)
	if f
		str = f\read('*a')
		f\close()
		return str
	assert(nil, ('Failed to read "%s".')\format(path))

io.writeFile = (relativePath, str = '', openMode = 'w') ->
	assert(type(relativePath) == 'string', '"io.writeFile" expected a string as the first argument.')
	assert(type(str) == 'string', '"io.writeFile" expected a string as the second argument.')
	f = io.open(io.joinPaths(vars.paths.resources, relativePath), openMode)
	if f
		f\write(str)
		f\close()
		return true
	assert(nil, ('Failed to write to "%s".')\format(vars.paths.resources .. relativePath))

io.copyFile = (source, target, relativeSource = true) ->
	assert(type(source) == 'string', '"io.copyFile" expected a string as the first argument.')
	assert(type(target) == 'string', '"io.copyFile" expected a string as the second argument.')
	file = io.readFile(source, relativeSource, 'rb')
	io.writeFile(target, file, 'wb')

-- 'table' functions
table.find = (tbl, obj) ->
	assert(type(tbl) == 'table', '"table.find" expected a table as the first argument.')
	assert(obj ~= nil, '"table.find" expected a second argument')
	for key, value in pairs(tbl)
		return key if value == obj
	return nil

table.replace = (tbl, old, new) ->
	assert(type(tbl) == 'table', '"table.replace" expected a table as the first argument.')
	assert(old ~= nil, '"table.replace" expected a second argument')
	assert(new ~= nil, '"table.replace" expected a third argument')
	key = table.find(tbl, old)
	if key
		tbl[key] = new 
		return true
	return false

table.extend = (tbl1, tbl2) ->
	assert(type(tbl1) == 'table' and type(tbl2) == 'table', '"table.slice" expected a tables as its two arguments.')
	len = #tbl1
	for i, value in ipairs(tbl2)
		tbl1[len + i] = value
	for key, value in pairs(tbl2)
		if type(key) ~= 'number' or key % 1 ~= 0
			tbl1[key] = value

table.slice = (tbl, min, max = #tbl) ->
	assert(type(tbl) == 'table', '"table.slice" expected a table as the first argument.')
	assert(type(min) == 'number' and min % 1 == 0, '"table.slice" expected an integer as the second argument.')
	assert(type(max) == 'number' and max % 1 == 0, '"table.slice" expected an integer as the third argument.')
	return [tbl[i] for i = min, max]

table.reverse = (tbl) ->
	assert(type(tbl) == 'table', '"table.reverse" expected a table as the argument.')
	len = #tbl
	return if len < 2
	for i = 1, math.floor(len / 2)
		lower = i
		upper = len - i + 1
		tbl[lower], tbl[upper] = tbl[upper], tbl[lower]

table.shallowCopy = (tbl) ->
	assert(type(tbl) == 'table', '"table.shallowCopy" expected a table as the argument.')
	return {key, value for key, value in pairs(tbl)}

table.deepCopy = (tbl) ->
	assert(type(tbl) == 'table', '"table.deepCopy" expected a table as the argument.')
	copy = {}
	for key, value in pairs(tbl)
		copy[key] = if type(value) == 'table' then table.deepCopy(value) else value
	return copy

table.shallowMerge = (source, target) ->
	assert(type(source) == 'table' and type(target) == 'table', '"table.shallowMerge" expected tables as arguments.')
	for key, value in pairs(source)
		target[key] = value
	return target

table.deepMerge = (source, target) ->
	assert(type(source) == 'table' and type(target) == 'table', '"table.deepMerge" expected tables as arguments.')
	for key, value in pairs(source)
		target[key] = if type(value) == 'table' and type(target[key]) == 'table' then table.deepCopy(value, target[key]) else value
	return target

-- 'math' functions
math.round = (float) -> return if float % 1 < 0.5 then math.floor(float) else math.ceil(float)

-- Misc functions
package = {
	loaded: {}
}

export require = (modulePath) ->
	assert(type(modulePath) == 'string', '"require" expected a string as the argument.')
	return package.loaded[modulePath] if package.loaded[modulePath] ~= nil
	partialPath = {}
	for part in *modulePath\split('%.')
		table.insert(partialPath, part)
	absolutePath = io.joinPaths(vars.paths.resources, table.concat(partialPath, '\\') .. '.lua')
	unless io.fileExists(absolutePath, false)
		absolutePath = io.joinPaths(vars.paths.resources, table.concat(partialPath, '\\') .. '\\init.lua')
	assert(io.fileExists(absolutePath, false), ('The module "%s" does not exist at "%s".')\format(modulePath, absolutePath))
	func, err = loadfile(absolutePath)
	assert(func, err) unless func
	mod = dofile(absolutePath)
	package.loaded[modulePath] = mod
	return mod

return module_info

-- Changelog:
-- Version 1.0.0 - 2018/MM/DD:
-- - Initial release
