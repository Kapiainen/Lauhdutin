local Config
do
  local _class_0
  local _base_0 = {
    isActive = function(self)
      return self.active == 1
    end,
    getX = function(self)
      return self.windowX
    end,
    getY = function(self)
      return self.windowY
    end,
    getZ = function(self)
      return self.alwaysOnTop
    end,
    isClickThrough = function(self)
      return self.clickThrough == 1
    end,
    isDraggable = function(self)
      return self.draggable == 1
    end,
    snapsToEdges = function(self)
      return self.snapEdges == 1
    end,
    isKeptOnScreen = function(self)
      return self.keepOnScreen == 1
    end,
    getLoadOrder = function(self)
      return self.loadOrder
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, str)
      assert(type(str) == 'string' and str ~= '', 'shared.utility.Config')
      self.active = tonumber(str:match('Active=(%d+)')) or 0
      self.windowX = tonumber(str:match('WindowX=(%d+)')) or 0
      self.windowY = tonumber(str:match('WindowY=(%d+)')) or 0
      self.clickThrough = tonumber(str:match('ClickThrough=(%d+)')) or 0
      self.draggable = tonumber(str:match('Draggable=(%d+)')) or 0
      self.snapEdges = tonumber(str:match('SnapEdges=(%d+)')) or 0
      self.keepOnScreen = tonumber(str:match('KeepOnScreen=(%d+)')) or 0
      self.alwaysOnTop = tonumber(str:match('AlwaysOnTop=(%d+)')) or 0
      self.loadOrder = tonumber(str:match('LoadOrder=(%d+)')) or 0
    end,
    __base = _base_0,
    __name = "Config"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Config = _class_0
end
local lookup = {
  [195] = {
    [96] = {
      ' ',
      '\160'
    },
    [97] = {
      '¡',
      '\161'
    },
    [98] = {
      '¢',
      '\162'
    },
    [99] = {
      '£',
      '\163'
    },
    [100] = {
      '¤',
      '\164'
    },
    [101] = {
      '¥',
      '\165'
    },
    [102] = {
      '¦',
      '\166'
    },
    [103] = {
      '§',
      '\167'
    },
    [104] = {
      '¨',
      '\168'
    },
    [105] = {
      '©',
      '\169'
    },
    [106] = {
      'ª',
      '\170'
    },
    [107] = {
      '«',
      '\171'
    },
    [108] = {
      '¬',
      '\172'
    },
    [110] = {
      '®',
      '\174'
    },
    [111] = {
      '¯',
      '\175'
    },
    [112] = {
      '°',
      '\176'
    },
    [113] = {
      '±',
      '\177'
    },
    [114] = {
      '²',
      '\178'
    },
    [115] = {
      '³',
      '\179'
    },
    [116] = {
      '´',
      '\180'
    },
    [117] = {
      'µ',
      '\181'
    },
    [118] = {
      '¶',
      '\182'
    },
    [119] = {
      '·',
      '\183'
    },
    [120] = {
      '¸',
      '\184'
    },
    [121] = {
      '¹',
      '\185'
    },
    [122] = {
      'º',
      '\186'
    },
    [123] = {
      '»',
      '\187'
    },
    [124] = {
      '¼',
      '\188'
    },
    [125] = {
      '½',
      '\189'
    },
    [126] = {
      '¾',
      '\190'
    },
    [127] = {
      '¿',
      '\191'
    },
    [128] = {
      'À',
      '\192'
    },
    [129] = {
      'Á',
      '\193'
    },
    [130] = {
      'Â',
      '\194'
    },
    [131] = {
      'Ã',
      '\195'
    },
    [132] = {
      'Ä',
      '\196'
    },
    [133] = {
      'Å',
      '\197'
    },
    [134] = {
      'Æ',
      '\198'
    },
    [135] = {
      'Ç',
      '\199'
    },
    [136] = {
      'È',
      '\200'
    },
    [137] = {
      'É',
      '\201'
    },
    [138] = {
      'Ê',
      '\202'
    },
    [139] = {
      'Ë',
      '\203'
    },
    [140] = {
      'Ì',
      '\204'
    },
    [141] = {
      'Í',
      '\205'
    },
    [142] = {
      'Î',
      '\206'
    },
    [143] = {
      'Ï',
      '\207'
    },
    [144] = {
      'Ð',
      '\208'
    },
    [145] = {
      'Ñ',
      '\209'
    },
    [146] = {
      'Ò',
      '\210'
    },
    [147] = {
      'Ó',
      '\211'
    },
    [148] = {
      'Ô',
      '\212'
    },
    [149] = {
      'Õ',
      '\213'
    },
    [150] = {
      'Ö',
      '\214'
    },
    [151] = {
      '×',
      '\215'
    },
    [152] = {
      'Ø',
      '\216'
    },
    [153] = {
      'Ù',
      '\217'
    },
    [154] = {
      'Ú',
      '\218'
    },
    [155] = {
      'Û',
      '\219'
    },
    [156] = {
      'Ü',
      '\220'
    },
    [157] = {
      'Ý',
      '\221'
    },
    [158] = {
      'Þ',
      '\222'
    },
    [159] = {
      'ß',
      '\223'
    },
    [160] = {
      'à',
      '\224'
    },
    [161] = {
      'á',
      '\225'
    },
    [162] = {
      'â',
      '\226'
    },
    [163] = {
      'ã',
      '\227'
    },
    [164] = {
      'ä',
      '\228'
    },
    [165] = {
      'å',
      '\229'
    },
    [166] = {
      'æ',
      '\230'
    },
    [167] = {
      'ç',
      '\231'
    },
    [168] = {
      'è',
      '\232'
    },
    [169] = {
      'é',
      '\233'
    },
    [170] = {
      'ê',
      '\234'
    },
    [171] = {
      'ë',
      '\235'
    },
    [172] = {
      'ì',
      '\236'
    },
    [173] = {
      'í',
      '\237'
    },
    [174] = {
      'î',
      '\238'
    },
    [175] = {
      'ï',
      '\239'
    },
    [176] = {
      'ð',
      '\240'
    },
    [177] = {
      'ñ',
      '\241'
    },
    [178] = {
      'ò',
      '\242'
    },
    [179] = {
      'ó',
      '\243'
    },
    [180] = {
      'ô',
      '\244'
    },
    [181] = {
      'õ',
      '\245'
    },
    [182] = {
      'ö',
      '\246'
    },
    [183] = {
      '÷',
      '\247'
    },
    [184] = {
      'ø',
      '\248'
    },
    [185] = {
      'ù',
      '\249'
    },
    [186] = {
      'ú',
      '\250'
    },
    [187] = {
      'û',
      '\251'
    },
    [188] = {
      'ü',
      '\252'
    },
    [189] = {
      'ý',
      '\253'
    },
    [190] = {
      'þ',
      '\254'
    },
    [191] = {
      'ÿ',
      '\255'
    }
  }
}
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
  waitCommand = 'ping -n 2 127.0.0.1 > nul',
  parseVDF = function(file)
    local _exp_0 = type(file)
    if 'string' == _exp_0 then
      return parseVDF(file:splitIntoLines())
    elseif 'table' == _exp_0 then
      return parseVDF(file)
    else
      return assert(nil, ('"parseVDF" does not support the "%s" type as its argument.'):format(type(file)))
    end
  end,
  replaceUnsupportedChars = function(str)
    assert(type(str) == 'string', 'shared.utility.replaceUnsupportedChars')
    local result = ''
    local charsToReplace = { }
    local hasCharsToDrop = false
    local hasCharsToReplace = false
    for char in str:gmatch('[%z\1-\127\194-\255][\128-\191]*') do
      local _continue_0 = false
      repeat
        local lookupValue = nil
        local bytes = {
          char:byte(1, -1)
        }
        if #bytes > 1 then
          lookupValue = lookup
          for _index_0 = 1, #bytes do
            local _continue_0 = false
            repeat
              local byte = bytes[_index_0]
              if lookupValue == nil then
                _continue_0 = true
                break
              end
              lookupValue = lookupValue[byte]
              _continue_0 = true
            until true
            if not _continue_0 then
              break
            end
          end
          if lookupValue == nil then
            hasCharsToDrop = true
            _continue_0 = true
            break
          end
          charsToReplace[lookupValue[1]] = lookupValue[2]
          hasCharsToReplace = true
        end
        result = result .. char
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    if hasCharsToReplace then
      for find, replace in pairs(charsToReplace) do
        result = result:gsub(find, replace)
      end
    elseif not hasCharsToDrop or #result == 0 then
      result = str
    end
    return result
  end,
  getConfig = function(name)
    assert(type(name) == 'string', 'shared.utility.getConfig')
    local path = io.joinPaths(SKIN:GetVariable('SETTINGSPATH'), 'Rainmeter.ini')
    local rainmeterINI = io.readFile(path, false)
    local pattern = '%[' .. name .. '%][^%[]+'
    local starts, ends = rainmeterINI:find(pattern)
    if starts == nil or ends == nil then
      return nil
    end
    return Config(rainmeterINI:sub(starts, ends))
  end,
  getConfigs = function(names)
    local path = io.joinPaths(SKIN:GetVariable('SETTINGSPATH'), 'Rainmeter.ini')
    local rainmeterINI = io.readFile(path, false)
    local configs = { }
    for _index_0 = 1, #names do
      local _continue_0 = false
      repeat
        local name = names[_index_0]
        local pattern = '%[' .. name .. '%][^%[]+'
        local starts, ends = rainmeterINI:find(pattern)
        if starts == nil or ends == nil then
          _continue_0 = true
          break
        end
        table.insert(configs, Config(rainmeterINI:sub(starts, ends)))
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    return configs
  end,
  getConfigMonitor = function(config)
    assert(config.__class == Config, 'shared.utility.getConfigMonitor')
    local x = config:getX()
    local y = config:getY()
    for i = 1, 8 do
      local _continue_0 = false
      repeat
        do
          local monitorX = tonumber(SKIN:GetVariable(('SCREENAREAX@%d'):format(i)))
          local monitorY = tonumber(SKIN:GetVariable(('SCREENAREAY@%d'):format(i)))
          local monitorWidth = tonumber(SKIN:GetVariable(('SCREENAREAWIDTH@%d'):format(i)))
          local monitorHeight = tonumber(SKIN:GetVariable(('SCREENAREAHEIGHT@%d'):format(i)))
          if x < monitorX or x > (monitorX + monitorWidth - 1) then
            _continue_0 = true
            break
          end
          if y < monitorY or y > (monitorY + monitorHeight - 1) then
            _continue_0 = true
            break
          end
          return i
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    return nil
  end,
  centerOnMonitor = function(width, height, screen)
    if screen == nil then
      screen = 1
    end
    assert(type(width) == 'number', 'shared.utility.centerOnMonitor')
    assert(type(height) == 'number', 'shared.utility.centerOnMonitor')
    assert(type(screen) == 'number', 'shared.utility.centerOnMonitor')
    local monitorX = tonumber(SKIN:GetVariable(('SCREENAREAX@%d'):format(screen)))
    local monitorY = tonumber(SKIN:GetVariable(('SCREENAREAY@%d'):format(screen)))
    local monitorWidth = tonumber(SKIN:GetVariable(('SCREENAREAWIDTH@%d'):format(screen)))
    local monitorHeight = tonumber(SKIN:GetVariable(('SCREENAREAHEIGHT@%d'):format(screen)))
    local x = math.round(monitorX + (monitorWidth - width) / 2)
    local y = math.round(monitorY + (monitorHeight - height) / 2)
    return x, y
  end
}
