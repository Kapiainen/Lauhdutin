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
        assert(lines[i + 1]:match('^%s*{%s*$') ~= nil, 'The VDF parser expected "{".')
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
            assert(nil, ('The VDF parser encountered unexpected input on line %d: %s.'):format(i, lines[i]))
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
  parse = function(file)
    local _exp_0 = type(file)
    if 'string' == _exp_0 then
      return parseVDF(file:splitIntoLines())
    elseif 'table' == _exp_0 then
      return parseVDF(file)
    else
      return assert(nil, ('The VDF parser does not support the "%s" type as its argument.'):format(type(file)))
    end
  end
}
