HandshakeSearch = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%s)" "#ROOTCONFIG#\\Search"]'):format(tostring(STATE.STACK_NEXT_FILTER)))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Search = function(str, stack)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('Searching for:', str)
    local games
    if stack then
      games = STATE.GAMES
    else
      games = nil
    end
    COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.TITLE, {
      input = str,
      games = games,
      stack = stack
    })
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
