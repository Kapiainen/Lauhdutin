local titles = {
  settings = 'ContextTitleSettings',
  openShortcutsFolder = 'ContextTitleOpenShortcutsFolder',
  executeStoppingBangs = 'ContextTitleExecuteStoppingBangs',
  hideGamesStatus = 'ContextTitleHideGamesStatus',
  unhideGameStatus = 'ContextTitleUnhideGameStatus',
  removeGamesStatus = 'ContextTitleRemoveGamesStatus',
  detectGames = 'ContextTitleDetectGames',
  addGame = 'ContextTitleAddGame'
}
local set
set = function(title, key, default)
  return SKIN:Bang(('[!SetVariable "%s" "%s"]'):format(title, LOCALIZATION:get(key, default)))
end
local setStartHidingGames
setStartHidingGames = function()
  return set(titles.hideGamesStatus, 'main_context_title_start_hiding_games', 'Start hiding games')
end
local setStopHidingGames
setStopHidingGames = function()
  return set(titles.hideGamesStatus, 'main_context_title_stop_hiding_games', 'Stop hiding games')
end
local setStartUnhidingGames
setStartUnhidingGames = function()
  return set(titles.unhideGameStatus, 'main_context_title_start_unhiding_games', 'Start unhiding games')
end
local setStopUnhidingGames
setStopUnhidingGames = function()
  return set(titles.unhideGameStatus, 'main_context_title_stop_unhiding_games', 'Stop unhiding games')
end
local setStartRemovingGames
setStartRemovingGames = function()
  return set(titles.removeGamesStatus, 'main_context_title_start_removing_games', 'Start removing games')
end
local setStopRemovingGames
setStopRemovingGames = function()
  return set(titles.removeGamesStatus, 'main_context_title_stop_removing_games', 'Stop removing games')
end
local ContextMenu
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      set(titles.settings, 'main_context_title_settings', 'Settings')
      set(titles.openShortcutsFolder, 'main_context_title_open_shortcuts_folder', 'Open shortcuts folder')
      set(titles.executeStoppingBangs, 'main_context_title_execute_stopping_bangs', 'Execute stopping bangs')
      setStartHidingGames()
      setStartUnhidingGames()
      setStartRemovingGames()
      set(titles.detectGames, 'main_context_title_detect_games', 'Detect games')
      set(titles.addGame, 'main_context_title_add_game', 'Add a game')
      COMPONENTS.SIGNAL:register(SIGNALS.START_HIDING_GAMES, function()
        setStopHidingGames()
        setStartUnhidingGames()
        return setStartRemovingGames()
      end)
      COMPONENTS.SIGNAL:register(SIGNALS.STOP_HIDING_GAMES, function()
        return setStartHidingGames()
      end)
      COMPONENTS.SIGNAL:register(SIGNALS.START_UNHIDING_GAMES, function()
        setStartHidingGames()
        setStopUnhidingGames()
        return setStartRemovingGames()
      end)
      COMPONENTS.SIGNAL:register(SIGNALS.STOP_UNHIDING_GAMES, function()
        return setStartUnhidingGames()
      end)
      COMPONENTS.SIGNAL:register(SIGNALS.START_REMOVING_GAMES, function()
        setStartHidingGames()
        setStartUnhidingGames()
        return setStopRemovingGames()
      end)
      return COMPONENTS.SIGNAL:register(SIGNALS.STOP_REMOVING_GAMES, function()
        return setStartRemovingGames()
      end)
    end,
    __base = _base_0,
    __name = "ContextMenu"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ContextMenu = _class_0
end
OnContextExecuteStoppingBangs = function()
  local success, err = pcall(function()
    return COMPONENTS.PROCESS:stopMonitoring()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnContextToggleHideGames = function()
  local success, err = pcall(function()
    if STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME then
      SKIN:Bang(('[!SetVariable "ContextTitleHideGamesStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_start_hiding_games', 'Start hiding games')))
      STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
      return 
    elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME then
      ToggleUnhideGames()
    elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME then
      ToggleRemoveGames()
    end
    COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.HIDDEN, {
      state = false,
      stack = true,
      games = STATE.GAMES
    })
    local games = COMPONENTS.LIBRARY:get()
    if #games == 0 then
      COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.HIDDEN, {
        state = false
      })
      games = COMPONENTS.LIBRARY:get()
      if #games == 0 then
        return 
      else
        STATE.GAMES = games
        STATE.SCROLL_INDEX = 1
        COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
      end
    else
      STATE.GAMES = games
      COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
    end
    SKIN:Bang(('[!SetVariable "ContextTitleHideGamesStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_stop_hiding_games', 'Stop hiding games')))
    STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnContextToggleUnhideGames = function()
  local success, err = pcall(function()
    if STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME then
      SKIN:Bang(('[!SetVariable "ContextTitleUnhideGameStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_start_unhiding_games', 'Start unhiding games')))
      STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
      return 
    elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME then
      ToggleHideGames()
    elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME then
      ToggleRemoveGames()
    end
    COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.HIDDEN, {
      state = true,
      stack = true,
      games = STATE.GAMES
    })
    local games = COMPONENTS.LIBRARY:get()
    if #games == 0 then
      COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.HIDDEN, {
        state = true
      })
      games = COMPONENTS.LIBRARY:get()
      if #games == 0 then
        return 
      else
        STATE.GAMES = games
        STATE.SCROLL_INDEX = 1
        COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
      end
    else
      STATE.GAMES = games
      COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
    end
    SKIN:Bang(('[!SetVariable "ContextTitleUnhideGameStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_stop_unhiding_games', 'Stop unhiding games')))
    STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnContextToggleRemoveGames = function()
  local success, err = pcall(function()
    if STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME then
      SKIN:Bang(('[!SetVariable "ContextTitleRemoveGamesStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_start_removing_games', 'Start removing games')))
      STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
      return 
    elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME then
      ToggleHideGames()
    elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME then
      ToggleUnhideGames()
    end
    if #STATE.GAMES == 0 then
      COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.NONE)
      STATE.GAMES = COMPONENTS.LIBRARY:get()
      STATE.SCROLL_INDEX = 1
      COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
    end
    if #STATE.GAMES == 0 then
      return 
    end
    SKIN:Bang(('[!SetVariable "ContextTitleRemoveGamesStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_stop_removing_games', 'Stop removing games')))
    STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnContextTriggerGameDetection = function()
  local success, err = pcall(function()
    local games = io.readJSON(STATE.PATHS.GAMES)
    games.updated = nil
    io.writeJSON(STATE.PATHS.GAMES, games)
    return SKIN:Bang("[!Refresh]")
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnContextAddGame = function()
  local success, err = pcall(function()
    return SKIN:Bang('[!ActivateConfig "#ROOTCONFIG#\\NewGame"]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
return ContextMenu
