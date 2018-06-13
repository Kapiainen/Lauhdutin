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
string.replaceUnsupportedChars = function(str)
  assert(type(str) == 'string', 'shared.string.replaceUnsupportedChars')
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
end