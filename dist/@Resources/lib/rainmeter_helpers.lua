local module_info = {
  name = 'Rainmeter helpers',
  author = 'Kapiainen',
  description = 'A module with some helper functions for scripting in the Lua environment provided by Rainmeter.',
  version = {
    major = 1,
    minor = 0,
    patch = 0
  },
  license = 'The MIT License\n\nCopyright 2018 Kapiainen\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the "Software"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in\nall copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\nTHE SOFTWARE.'
}
local vars = {
  paths = {
    executable = SKIN:GetVariable('PROGRAMPATH') .. 'Rainmeter.exe',
    resources = SKIN:GetVariable('@')
  },
  currentConfig = SKIN:GetVariable('CURRENTCONFIG')
}
string.startsWith = function(str, prefix)
  assert(type(str) == 'string', '"string.startsWith" expected a string as the first argument.')
  assert(type(prefix) == 'string', '"string.startsWith" expected a string as the second argument.')
  return str:match('^(' .. prefix .. '.-)$') ~= nil
end
string.endsWith = function(str, suffix)
  assert(type(str) == 'string', '"string.endsWith" expected a string as the first argument.')
  assert(type(suffix) == 'string', '"string.endsWith" expected a string as the second argument.')
  return str:match('^(.-' .. suffix .. ')$') ~= nil
end
string.trim = function(str)
  assert(type(str) == 'string', '"string.trim" expected a string as the argument.')
  return str:match('^%s*(.-)%s*$')
end
string.split = function(str, pattern)
  assert(type(str) == 'string', '"string.split" expected a string as the first argument.')
  assert(type(pattern) == 'string', '"string.split" expected a string as the second argument.')
  local _accum_0 = { }
  local _len_0 = 1
  for match in str:gmatch('([^' .. pattern .. ']+)') do
    _accum_0[_len_0] = match
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
string.splitIntoLines = function(str)
  assert(type(str) == 'string', '"string.splitIntoLines" expected a string as the first argument.')
  return str:split('\n\r')
end
string.splitIntoChars = function(str)
  assert(type(str) == 'string', '"string.splitIntoChars" expected a string as the first argument.')
  local _accum_0 = { }
  local _len_0 = 1
  for char in str:gmatch('.') do
    _accum_0[_len_0] = char
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
string.splitIntoWords = function(str)
  assert(type(str) == 'string', '"string.splitIntoWords" expected a string as the first argument.')
  local _accum_0 = { }
  local _len_0 = 1
  for word in str:gmatch('[^%s%p]*') do
    if word ~= nil and word ~= '' then
      _accum_0[_len_0] = word
      _len_0 = _len_0 + 1
    end
  end
  return _accum_0
end
io.joinPaths = function(...)
  local args = {
    n = select('#', ...),
    ...
  }
  assert(type(args[1]) == 'string', ('"io.joinPaths" expected every argument to be a string, but argument #%d was %s.'):format(1, type(args[1])))
  local path = args[1]
  for i = 2, args.n do
    assert(type(args[i]) == 'string', ('"io.joinPaths" expected every argument to be a string, but argument #%d was %s.'):format(i, type(args[i])))
    if not (path:endsWith('\\')) then
      path = path .. '\\'
    end
    path = path .. args[i]
  end
  return path
end
io.splitPath = function(path)
  assert(type(path) == 'string', '"io.split" expected a string argument.')
  path = path:reverse()
  local tail, head = path:match('^([^\\]+)(.*)$')
  if head ~= nil and tail ~= nil then
    return head:reverse(), tail:reverse()
  end
  return nil, nil
end
io.absolutePath = function(relPath)
  assert(type(relPath) == 'string', '"io.absolutePath" expected a string argument.')
  return io.joinPaths(vars.paths.resources, relPath)
end
io.fileExists = function(path, pathIsRelative)
  if pathIsRelative == nil then
    pathIsRelative = true
  end
  assert(type(path) == 'string', '"io.fileExists" expected a string as the first argument.')
  assert(type(pathIsRelative) == 'boolean', '"io.fileExists" expected a boolean as the second argument.')
  if pathIsRelative then
    path = io.joinPaths(vars.paths.resources, path)
  end
  local f = io.open(path, 'r')
  if f then
    f:close()
  else
    return false
  end
  return true
end
io.readFile = function(path, pathIsRelative, openMode)
  if pathIsRelative == nil then
    pathIsRelative = true
  end
  if openMode == nil then
    openMode = 'r'
  end
  assert(type(path) == 'string', '"io.readFile" expected a string as the first argument.')
  assert(type(pathIsRelative) == 'boolean', '"io.readFile" expected a boolean as the second argument.')
  assert((openMode:find('r')) ~= nil, '"io.readFile" expected "openMode" to contain "r".')
  if pathIsRelative then
    path = io.joinPaths(vars.paths.resources, path)
  end
  local f = io.open(path, openMode)
  if f then
    local str = f:read('*a')
    f:close()
    return str
  end
  return assert(nil, ('Failed to read "%s".'):format(path))
end
io.writeFile = function(relativePath, str, openMode)
  if str == nil then
    str = ''
  end
  if openMode == nil then
    openMode = 'w'
  end
  assert(type(relativePath) == 'string', '"io.writeFile" expected a string as the first argument.')
  assert(type(str) == 'string', '"io.writeFile" expected a string as the second argument.')
  local f = io.open(io.joinPaths(vars.paths.resources, relativePath), openMode)
  if f then
    f:write(str)
    f:close()
    return true
  end
  return assert(nil, ('Failed to write to "%s".'):format(vars.paths.resources .. relativePath))
end
io.copyFile = function(source, target, relativeSource)
  if relativeSource == nil then
    relativeSource = true
  end
  assert(type(source) == 'string', '"io.copyFile" expected a string as the first argument.')
  assert(type(target) == 'string', '"io.copyFile" expected a string as the second argument.')
  local file = io.readFile(source, relativeSource, 'rb')
  return io.writeFile(target, file, 'wb')
end
table.find = function(tbl, obj)
  assert(type(tbl) == 'table', '"table.find" expected a table as the first argument.')
  assert(obj ~= nil, '"table.find" expected a second argument')
  for key, value in pairs(tbl) do
    if value == obj then
      return key
    end
  end
  return nil
end
table.replace = function(tbl, old, new)
  assert(type(tbl) == 'table', '"table.replace" expected a table as the first argument.')
  assert(old ~= nil, '"table.replace" expected a second argument')
  assert(new ~= nil, '"table.replace" expected a third argument')
  local key = table.find(tbl, old)
  if key then
    tbl[key] = new
    return true
  end
  return false
end
table.extend = function(tbl1, tbl2)
  assert(type(tbl1) == 'table' and type(tbl2) == 'table', '"table.slice" expected a tables as its two arguments.')
  local len = #tbl1
  for i, value in ipairs(tbl2) do
    tbl1[len + i] = value
  end
  for key, value in pairs(tbl2) do
    if type(key) ~= 'number' or key % 1 ~= 0 then
      tbl1[key] = value
    end
  end
end
table.slice = function(tbl, min, max)
  if max == nil then
    max = #tbl
  end
  assert(type(tbl) == 'table', '"table.slice" expected a table as the first argument.')
  assert(type(min) == 'number' and min % 1 == 0, '"table.slice" expected an integer as the second argument.')
  assert(type(max) == 'number' and max % 1 == 0, '"table.slice" expected an integer as the third argument.')
  local _accum_0 = { }
  local _len_0 = 1
  for i = min, max do
    _accum_0[_len_0] = tbl[i]
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
table.reverse = function(tbl)
  assert(type(tbl) == 'table', '"table.reverse" expected a table as the argument.')
  local len = #tbl
  if len < 2 then
    return 
  end
  for i = 1, math.floor(len / 2) do
    local lower = i
    local upper = len - i + 1
    tbl[lower], tbl[upper] = tbl[upper], tbl[lower]
  end
end
table.shallowCopy = function(tbl)
  assert(type(tbl) == 'table', '"table.shallowCopy" expected a table as the argument.')
  local _tbl_0 = { }
  for key, value in pairs(tbl) do
    _tbl_0[key] = value
  end
  return _tbl_0
end
table.deepCopy = function(tbl)
  assert(type(tbl) == 'table', '"table.deepCopy" expected a table as the argument.')
  local copy = { }
  for key, value in pairs(tbl) do
    if type(value) == 'table' then
      copy[key] = table.deepCopy(value)
    else
      copy[key] = value
    end
  end
  return copy
end
table.shallowMerge = function(source, target)
  assert(type(source) == 'table' and type(target) == 'table', '"table.shallowMerge" expected tables as arguments.')
  for key, value in pairs(source) do
    target[key] = value
  end
  return target
end
table.deepMerge = function(source, target)
  assert(type(source) == 'table' and type(target) == 'table', '"table.deepMerge" expected tables as arguments.')
  for key, value in pairs(source) do
    if type(value) == 'table' and type(target[key]) == 'table' then
      target[key] = table.deepCopy(value, target[key])
    else
      target[key] = value
    end
  end
  return target
end
math.round = function(float)
  if float % 1 < 0.5 then
    return math.floor(float)
  else
    return math.ceil(float)
  end
end
local package = {
  loaded = { }
}
require = function(modulePath)
  assert(type(modulePath) == 'string', '"require" expected a string as the argument.')
  if package.loaded[modulePath] ~= nil then
    return package.loaded[modulePath]
  end
  local partialPath = { }
  local _list_0 = modulePath:split('%.')
  for _index_0 = 1, #_list_0 do
    local part = _list_0[_index_0]
    table.insert(partialPath, part)
  end
  local absolutePath = io.joinPaths(vars.paths.resources, table.concat(partialPath, '\\') .. '.lua')
  if not (io.fileExists(absolutePath, false)) then
    absolutePath = io.joinPaths(vars.paths.resources, table.concat(partialPath, '\\') .. '\\init.lua')
  end
  assert(io.fileExists(absolutePath, false), ('The module "%s" does not exist at "%s".'):format(modulePath, absolutePath))
  local func, err = loadfile(absolutePath)
  if not (func) then
    assert(func, err)
  end
  local mod = dofile(absolutePath)
  package.loaded[modulePath] = mod
  return mod
end
return module_info
