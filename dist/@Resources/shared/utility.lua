local parseVDF
parseVDF = function(lines, start)
  if start == nil then
    start = 1
  end
  local result = { }
  local i = start - 1
  while i < #lines do
    local _continue_0 = false
    repeat
      i = i + 1
      local key = lines[i]:match('^%s*"([^"]+)"%s*$')
      if key ~= nil then
        assert(lines[i + 1]:match('^%s*{%s*$') ~= nil, '"parseVDF" expected "{".')
        local tbl
        tbl, i = parseVDF(lines, i + 2)
        result[key:lower()] = tbl
      else
        local value
        key, value = lines[i]:match('^%s*"([^"]+)"%s*"(.-)"%s*$')
        if key ~= nil and value ~= nil then
          result[key:lower()] = value
        else
          if lines[i]:match('^%s*}%s*$') then
            return result, i
          elseif lines[i]:match('^%s*//.*$') then
            _continue_0 = true
            break
          elseif lines[i]:match('^%s*"#base"%s*"([^"]+)"%s*$') then
            _continue_0 = true
            break
          else
            assert(nil, ('"parseVDF" encountered unexpected input on line %d: %s.'):format(i, lines[i]))
          end
        end
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return result, i
end
return {
  createJSONHelpers = function()
    local json = require('lib.json')
    assert(type(json) == 'table', 'shared.utility.createJSONHelpers')
    io.readJSON = function(path, pathIsRelative)
      if pathIsRelative == nil then
        pathIsRelative = true
      end
      return json.decode(io.readFile(path, pathIsRelative))
    end
    io.writeJSON = function(relativePath, tbl)
      assert(type(tbl) == 'table', 'io.writeJSON')
      return io.writeFile(relativePath, json.encode(tbl))
    end
  end,
  runCommand = function(parameter, output, callback, callbackArgs, state, outputType)
    if callbackArgs == nil then
      callbackArgs = { }
    end
    if state == nil then
      state = 'Hide'
    end
    if outputType == nil then
      outputType = 'UTF16'
    end
    assert(type(parameter) == 'string', 'shared.utility.runCommand')
    assert(type(output) == 'string', 'shared.utility.runCommand')
    assert(type(callback) == 'string', 'shared.utility.runCommand')
    SKIN:Bang(('[!SetOption "Command" "Parameter" "%s"]'):format(parameter))
    SKIN:Bang(('[!SetOption "Command" "OutputFile" "%s"]'):format(output))
    SKIN:Bang(('[!SetOption "Command" "OutputType" "%s"]'):format(outputType))
    SKIN:Bang(('[!SetOption "Command" "State" "%s"]'):format(state))
    SKIN:Bang(('[!SetOption "Command" "FinishAction" "[!CommandMeasure Script %s(%s)]"]'):format(callback, table.concat(callbackArgs, ', ')))
    SKIN:Bang('[!UpdateMeasure "Command"]')
    return SKIN:Bang('[!CommandMeasure "Command" "Run"]')
  end,
  runLastCommand = function()
    return SKIN:Bang('[!CommandMeasure "Command" "Run"]')
  end,
  parseVDF = function(file)
    local _exp_0 = type(file)
    if 'string' == _exp_0 then
      return parseVDF(file:splitIntoLines())
    elseif 'table' == _exp_0 then
      return parseVDF(file)
    else
      return assert(nil, ('"parseVDF" does not support the "%s" type as its argument.'):format(type(file)))
    end
  end
}
