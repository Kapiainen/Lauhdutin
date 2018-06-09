HandshakeSort = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%d, \'%s\')" "#ROOTCONFIG#\\Sort"]'):format(COMPONENTS.SETTINGS:getSorting(), STATE.VARIANT))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Sort = function(sortingType)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    COMPONENTS.SETTINGS:setSorting(sortingType)
    COMPONENTS.LIBRARY:sort(sortingType, STATE.GAMES)
    STATE.SCROLL_INDEX = 1
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
