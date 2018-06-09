OnMouseOverToolbar = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  if not (STATE.SKIN_VISIBLE) then
    return 
  end
  if STATE.SKIN_ANIMATION_PLAYING then
    return 
  end
  local success, err = pcall(function()
    COMPONENTS.TOOLBAR:show()
    COMPONENTS.SLOTS:unfocus()
    COMPONENTS.SLOTS:leave()
    COMPONENTS.ANIMATIONS:resetSlots()
    return COMPONENTS.ANIMATIONS:cancelAnimations()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnMouseLeaveToolbar = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  if not (STATE.SKIN_VISIBLE) then
    return 
  end
  if STATE.SKIN_ANIMATION_PLAYING then
    return 
  end
  local success, err = pcall(function()
    COMPONENTS.TOOLBAR:hide()
    COMPONENTS.SLOTS:focus()
    return COMPONENTS.SLOTS:hover()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnToolbarResetGames = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnToolbarSearch = function(stack)
  if not (STATE.INITIALIZED) then
    return 
  end
  STATE.STACK_NEXT_FILTER = stack
  log('OnToolbarSearch', stack)
  return SKIN:Bang(('[!ActivateConfig "#ROOTCONFIG#\\Search" "%sSearch.ini"]'):format(STATE.VARIANT))
end
OnToolbarSort = function(quick)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('OnToolbarSort')
    if quick then
      local sortingType = COMPONENTS.SETTINGS:getSorting() + 1
      if sortingType >= ENUMS.SORTING_TYPES.MAX then
        sortingType = 1
      end
      return Sort(sortingType)
    end
    local configName = ('%s\\Sort'):format(STATE.ROOT_CONFIG)
    local config = utility.getConfig(configName)
    if config ~= nil and config:isActive() then
      return SKIN:Bang(('[!DeactivateConfig "%s"]'):format(configName))
    end
    return SKIN:Bang(('[!ActivateConfig "%s" "%sSort.ini"]'):format(configName, STATE.VARIANT))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnToolbarReverseOrder = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('Reversing order of games')
    table.reverse(STATE.GAMES)
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnToolbarFilter = function(stack)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    STATE.STACK_NEXT_FILTER = stack
    local configName = ('%s\\Filter'):format(STATE.ROOT_CONFIG)
    local config = utility.getConfig(configName)
    if config ~= nil and config:isActive() then
      return HandshakeFilter()
    end
    return SKIN:Bang(('[!ActivateConfig "%s" "%sFilter.ini"]'):format(configName, STATE.VARIANT))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
