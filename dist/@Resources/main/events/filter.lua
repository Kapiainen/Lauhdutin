HandshakeFilter = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    local stack = tostring(STATE.STACK_NEXT_FILTER)
    local appliedFilters = '[]'
    if STATE.STACK_NEXT_FILTER then
      appliedFilters = json.encode(COMPONENTS.LIBRARY:getFilterStack()):gsub('"', '|')
    end
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%s, \'%s\', \'%s\')" "#ROOTCONFIG#\\Filter"]'):format(stack, appliedFilters, STATE.VARIANT))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Filter = function(filterType, stack, arguments)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('Filter', filterType, type(filterType), stack, type(stack), arguments)
    arguments = arguments:gsub('|', '"')
    arguments = json.decode(arguments)
    if stack then
      arguments.games = STATE.GAMES
    else
      arguments.games = nil
    end
    arguments.stack = stack
    COMPONENTS.LIBRARY:filter(filterType, arguments)
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
