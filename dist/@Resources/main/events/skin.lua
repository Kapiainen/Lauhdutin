Unload = function()
  local success, err = pcall(function()
    log('Unloading skin')
    COMPONENTS.LIBRARY:save()
    return COMPONENTS.SETTINGS:save()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnMouseOver = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    return setUpdateDivider(1)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local otherWindowsActive
otherWindowsActive = function()
  local rootConfigName = STATE.ROOT_CONFIG
  local configs = utility.getConfigs((function()
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = {
      'Search',
      'Sort',
      'Filter',
      'Game'
    }
    for _index_0 = 1, #_list_0 do
      local name = _list_0[_index_0]
      _accum_0[_len_0] = ('%s\\%s'):format(rootConfigName, name)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)())
  for _index_0 = 1, #configs do
    local config = configs[_index_0]
    if config:isActive() then
      return true
    end
  end
  return false
end
OnMouseLeave = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    COMPONENTS.ANIMATIONS:resetSlots()
    local animationType = COMPONENTS.SETTINGS:getSkinSlideAnimation()
    if STATE.VARIANT == 'Main' and STATE.SKIN_VISIBLE and animationType ~= ENUMS.SKIN_ANIMATIONS.NONE and not otherWindowsActive() then
      if COMPONENTS.ANIMATIONS:pushSkinSlide(animationType, false) then
        return 
      end
    end
    return setUpdateDivider(-1)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnMouseLeaveEnabler = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  if STATE.SKIN_VISIBLE then
    return 
  end
  local success, err = pcall(function()
    STATE.REVEALING_DELAY = COMPONENTS.SETTINGS:getSkinRevealingDelay()
    return setUpdateDivider(-1)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
TriggerGameDetection = function()
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
ToggleHideGames = function()
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
        updateSlots()
      end
    else
      STATE.GAMES = games
      updateSlots()
    end
    SKIN:Bang(('[!SetVariable "ContextTitleHideGamesStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_stop_hiding_games', 'Stop hiding games')))
    STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
ToggleUnhideGames = function()
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
        updateSlots()
      end
    else
      STATE.GAMES = games
      updateSlots()
    end
    SKIN:Bang(('[!SetVariable "ContextTitleUnhideGameStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_stop_unhiding_games', 'Stop unhiding games')))
    STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
ToggleRemoveGames = function()
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
      updateSlots()
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
OnBannerDownloadFinished = function()
  local success, err = pcall(function()
    log('Successfully downloaded a banner')
    local downloadedPath = io.joinPaths(STATE.PATHS.DOWNLOADFILE, SKIN:GetMeasure('Downloader'):GetOption('DownloadFile'))
    local game = table.remove(STATE.BANNER_QUEUE, 1)
    local bannerPath = io.joinPaths(STATE.PATHS.RESOURCES, game:getBanner())
    os.rename(downloadedPath, bannerPath)
    game:setBannerURL(nil)
    game:setExpectedBanner(nil)
    return startDownloadingBanner()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnBannerDownloadError = function()
  local success, err = pcall(function()
    log('Failed to download a banner')
    local game = table.remove(STATE.BANNER_QUEUE, 1)
    io.writeFile(game:getBanner():gsub('%..+', '%.failedToDownload'), '')
    game:setBanner(nil)
    game:setBannerURL(nil)
    return startDownloadingBanner()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnFinishedDownloadingBanners = function()
  local success, err = pcall(function()
    log('Finished downloading banners')
    utility.stopDownloader()
    return onInitialized()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
