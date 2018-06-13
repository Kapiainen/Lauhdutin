local Toolbar
do
  local _class_0
  local _base_0 = {
    hide = function(self)
      return SKIN:Bang('[!HideMeterGroup "Toolbar"]')
    end,
    show = function(self)
      return SKIN:Bang('[!ShowMeterGroup "Toolbar"]')
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, settings)
      assert(type(settings) == 'table', 'main.toolbar.init.Toolbar')
      if not (settings:getLayoutToolbarAtTop()) then
        SKIN:Bang('[!SetOption "ToolbarBackground" "Y" "(#SkinHeight# - #ToolbarHeight#)]')
        SKIN:Bang('[!SetOption "ToolbarEnabler" "Y" "(#SkinHeight# - 1)]')
        return SKIN:Bang('[!UpdateMeterGroup "Toolbar"]')
      end
    end,
    __base = _base_0,
    __name = "Toolbar"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Toolbar = _class_0
end
OnToolbarMouseOver = function()
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
OnToolbarMouseLeave = function()
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
OnToolbarSearch = function(stack)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('OnToolbarSearch', stack)
    return COMPONENTS.SIGNAL:emit(SIGNALS.OPEN_SEARCH_MENU, stack)
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
    log('Resetting list of games')
    return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_GAMES, COMPONENTS.LIBRARY:get())
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnToolbarSort = function(quick)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('OnToolbarSort', quick)
    return COMPONENTS.SIGNAL:emit(SIGNALS.OPEN_SORTING_MENU, quick)
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
    return COMPONENTS.SIGNAL:emit(SIGNALS.REVERSE_GAMES)
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
    log('OnToolbarFilter', stack)
    return COMPONENTS.SIGNAL:emit(SIGNALS.OPEN_FILTERING_MENU, stack)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
return Toolbar
