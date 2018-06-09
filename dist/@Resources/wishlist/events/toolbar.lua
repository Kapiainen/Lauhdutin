require('main.events.toolbar')
OnToolbarSort = function(quick)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('OnToolbarSort')
    if quick then
      local sortingType
      local _exp_0 = COMPONENTS.SETTINGS:getSorting()
      if ENUMS.SORTING_TYPES.ALPHABETICALLY == _exp_0 then
        sortingType = ENUMS.SORTING_TYPES.PRICE
      elseif ENUMS.SORTING_TYPES.PRICE == _exp_0 then
        sortingType = ENUMS.SORTING_TYPES.ALPHABETICALLY
      else
        sortingType = ENUMS.SORTING_TYPES.ALPHABETICALLY
      end
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
