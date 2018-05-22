RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
local utility = nil
local json = nil
local Game = nil
LOCALIZATION = nil
STATE = {
  INITIALIZED = false,
  PATHS = {
    RESOURCES = nil,
    DOWNLOADFILE = nil,
    GAMES = 'games.json'
  },
  ROOT_CONFIG = nil,
  SETTINGS = { },
  NUM_SLOTS = 0,
  SCROLL_INDEX = 1,
  SCROLL_STEP = 1,
  LEFT_CLICK_ACTION = 1,
  PLATFORM_NAMES = { },
  PLATFORM_RUNNING_STATUS = { },
  GAMES = { },
  REVEALING_DELAY = 0,
  SKIN_VISIBLE = true,
  SKIN_ANIMATION_PLAYING = false,
  PLATFORM_ENABLED_STATUS = nil,
  PLATFORM_QUEUE = nil,
  BANNER_QUEUE = nil,
  GAME_BEING_MODIFIED = nil
}
COMPONENTS = {
  STATUS = nil,
  SETTINGS = nil,
  LIBRARY = nil
}
log = function(...)
  if STATE.LOGGING == true then
    return print(...)
  end
end
local downloadFile
downloadFile = function(url, path, finishCallback, errorCallback)
  log('Attempting to download file:', url, path, finishCallback, errorCallback)
  assert(type(url) == 'string', 'main.init.downloadFile')
  assert(type(path) == 'string', 'main.init.downloadFile')
  assert(type(finishCallback) == 'string', 'main.init.downloadFile')
  assert(type(errorCallback) == 'string', 'main.init.downloadFile')
  SKIN:Bang(('[!SetOption "Downloader" "URL" "%s"]'):format(url))
  SKIN:Bang(('[!SetOption "Downloader" "DownloadFile" "%s"]'):format(path))
  SKIN:Bang(('[!SetOption "Downloader" "FinishAction" "[!CommandMeasure Script %s()]"]'):format(finishCallback))
  SKIN:Bang(('[!SetOption "Downloader" "OnConnectErrorAction" "[!CommandMeasure Script %s()]"]'):format(errorCallback))
  SKIN:Bang(('[!SetOption "Downloader" "OnRegExpErrorAction" "[!CommandMeasure Script %s()]"]'):format(errorCallback))
  SKIN:Bang(('[!SetOption "Downloader" "OnDownloadErrorAction" "[!CommandMeasure Script %s()]"]'):format(errorCallback))
  SKIN:Bang('[!SetOption "Downloader" "UpdateDivider" "63"]')
  SKIN:Bang('[!SetOption "Downloader" "Disabled" "0"]')
  return SKIN:Bang('[!UpdateMeasure "Downloader"]')
end
local stopDownloader
stopDownloader = function()
  log('Stopping downloader')
  SKIN:Bang('[!SetOption "Downloader" "UpdateDivider" "-1"]')
  SKIN:Bang('[!SetOption "Downloader" "Disabled" "1"]')
  return SKIN:Bang('[!UpdateMeasure "Downloader"]')
end
local downloadBanner
downloadBanner = function(game)
  log('Downloading a banner for', game:getTitle())
  assert(game ~= nil, 'main.init.downloadBanner')
  assert(game.__class == Game, 'main.init.downloadBanner')
  local bannerPath = game:getBanner():reverse():match('^([^%.]+%.[^\\]+)'):reverse()
  return downloadFile(game:getBannerURL(), bannerPath, 'OnBannerDownloadFinished', 'OnBannerDownloadError')
end
setUpdateDivider = function(value)
  assert(type(value) == 'number' and value % 1 == 0 and value ~= 0, 'main.init.setUpdateDivider')
  SKIN:Bang(('[!SetOption "Script" "UpdateDivider" "%d"]'):format(value))
  return SKIN:Bang('[!UpdateMeasure "Script"]')
end
local startDetectingPlatformGames
startDetectingPlatformGames = function()
  COMPONENTS.STATUS:show(LOCALIZATION:get('main_status_detecting_platform_games', 'Detecting %s games'):format(STATE.PLATFORM_QUEUE[1]:getName()))
  local _exp_0 = STATE.PLATFORM_QUEUE[1]:getPlatformID()
  if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
    log('Starting to detect Windows shortcuts')
    return utility.runCommand(STATE.PLATFORM_QUEUE[1]:parseShortcuts())
  elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 then
    local url, path, finishCallback, errorCallback = STATE.PLATFORM_QUEUE[1]:downloadCommunityProfile()
    if url ~= nil then
      log('Attempting to download and parse the Steam community profile')
      return downloadFile(url, path, finishCallback, errorCallback)
    else
      log('Starting to detect Steam games')
      STATE.PLATFORM_QUEUE[1]:getLibraries()
      if STATE.PLATFORM_QUEUE[1]:hasLibrariesToParse() then
        return utility.runCommand(STATE.PLATFORM_QUEUE[1]:getACFs())
      else
        return OnFinishedDetectingPlatformGames()
      end
    end
  elseif ENUMS.PLATFORM_IDS.STEAM_SHORTCUTS == _exp_0 then
    log('Starting to detect non-Steam game shortcuts added to Steam')
    local games = STATE.PLATFORM_QUEUE[1]:generateGames()
    return OnFinishedDetectingPlatformGames()
  elseif ENUMS.PLATFORM_IDS.BATTLENET == _exp_0 then
    log('Starting to detect Blizzard Battle.net games')
    if STATE.PLATFORM_QUEUE[1]:hasUnprocessedPaths() then
      return utility.runCommand(STATE.PLATFORM_QUEUE[1]:identifyFolders())
    else
      return OnFinishedDetectingPlatformGames()
    end
  elseif ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
    log('Starting to detect GOG Galaxy games')
    return utility.runCommand(STATE.PLATFORM_QUEUE[1]:dumpDatabases())
  else
    return assert(nil, 'main.init.startDetectingPlatformGames')
  end
end
local detectGames
detectGames = function()
  COMPONENTS.STATUS:show(LOCALIZATION:get('main_status_detecting_games', 'Detecting games'))
  local platforms
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = require('main.platforms')
    for _index_0 = 1, #_list_0 do
      local Platform = _list_0[_index_0]
      _accum_0[_len_0] = Platform(COMPONENTS.SETTINGS)
      _len_0 = _len_0 + 1
    end
    platforms = _accum_0
  end
  log('Num platforms:', #platforms)
  COMPONENTS.PROCESS:registerPlatforms(platforms)
  STATE.PLATFORM_ENABLED_STATUS = { }
  STATE.PLATFORM_QUEUE = { }
  for _index_0 = 1, #platforms do
    local platform = platforms[_index_0]
    local enabled = platform:isEnabled()
    if enabled then
      platform:validate()
    end
    local platformID = platform:getPlatformID()
    STATE.PLATFORM_NAMES[platformID] = platform:getName()
    STATE.PLATFORM_ENABLED_STATUS[platformID] = enabled
    if platform:getPlatformProcess() ~= nil then
      STATE.PLATFORM_RUNNING_STATUS[platformID] = false
    end
    if enabled then
      table.insert(STATE.PLATFORM_QUEUE, platform)
    end
    log(' ' .. STATE.PLATFORM_NAMES[platformID] .. ' = ' .. tostring(enabled))
  end
  assert(#STATE.PLATFORM_QUEUE > 0, 'There are no enabled platforms.')
  STATE.BANNER_QUEUE = { }
  return startDetectingPlatformGames()
end
local startDownloadingBanner
startDownloadingBanner = function()
  while #STATE.BANNER_QUEUE > 0 do
    local _continue_0 = false
    repeat
      do
        if io.fileExists((STATE.BANNER_QUEUE[1]:getBanner():gsub('%..+', '%.failedToDownload'))) then
          table.remove(STATE.BANNER_QUEUE, 1)
          _continue_0 = true
          break
        end
        break
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  if #STATE.BANNER_QUEUE > 0 then
    log('Starting to download a banner')
    COMPONENTS.STATUS:show(LOCALIZATION:get('main_status_n_banners_to_download', '%d banners left to download'):format(#STATE.BANNER_QUEUE))
    return downloadBanner(STATE.BANNER_QUEUE[1])
  else
    STATE.BANNER_QUEUE = nil
    return OnFinishedDownloadingBanners()
  end
end
local updateSlots
updateSlots = function()
  local success, err = pcall(function()
    if STATE.SCROLL_INDEX < 1 then
      STATE.SCROLL_INDEX = 1
    elseif STATE.SCROLL_INDEX > #STATE.GAMES - STATE.NUM_SLOTS + 1 then
      if #STATE.GAMES > STATE.NUM_SLOTS then
        STATE.SCROLL_INDEX = #STATE.GAMES - STATE.NUM_SLOTS + 1
      else
        STATE.SCROLL_INDEX = 1
      end
    end
    if COMPONENTS.SLOTS:populate(STATE.GAMES, STATE.SCROLL_INDEX) then
      COMPONENTS.ANIMATIONS:resetSlots()
      return COMPONENTS.SLOTS:update()
    else
      SKIN:Bang(('[!SetOption "Slot1Text" "Text" "%s"]'):format(LOCALIZATION:get('main_no_games', 'No games to show')))
      COMPONENTS.ANIMATIONS:resetSlots()
      return COMPONENTS.SLOTS:update()
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local onInitialized
onInitialized = function()
  COMPONENTS.STATUS:hide()
  COMPONENTS.LIBRARY:finalize(STATE.PLATFORM_ENABLED_STATUS)
  STATE.PLATFORM_ENABLED_STATUS = nil
  COMPONENTS.LIBRARY:save()
  COMPONENTS.LIBRARY:sort(COMPONENTS.SETTINGS:getSorting())
  STATE.GAMES = COMPONENTS.LIBRARY:get()
  updateSlots()
  STATE.INITIALIZED = true
  local animationType = COMPONENTS.SETTINGS:getSkinSlideAnimation()
  if animationType ~= ENUMS.SKIN_ANIMATIONS.NONE then
    COMPONENTS.ANIMATIONS:pushSkinSlide(animationType, false)
    setUpdateDivider(1)
  end
  COMPONENTS.PROCESS:update()
  return log('Skin initialized')
end
local additionalEnums
additionalEnums = function()
  ENUMS.LEFT_CLICK_ACTIONS = {
    LAUNCH_GAME = 1,
    HIDE_GAME = 2,
    UNHIDE_GAME = 3,
    REMOVE_GAME = 4
  }
end
Initialize = function()
  STATE.PATHS.RESOURCES = SKIN:GetVariable('@')
  STATE.PATHS.DOWNLOADFILE = SKIN:GetVariable('CURRENTPATH') .. 'DownloadFile\\'
  STATE.ROOT_CONFIG = SKIN:GetVariable('ROOTCONFIG')
  dofile(('%s%s'):format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
  COMPONENTS.STATUS = require('shared.status')()
  local success, err = pcall(function()
    require('shared.enums')
    additionalEnums()
    Game = require('main.game')
    utility = require('shared.utility')
    utility.createJSONHelpers()
    json = require('lib.json')
    COMPONENTS.SETTINGS = require('shared.settings')()
    STATE.LOGGING = COMPONENTS.SETTINGS:getLogging()
    STATE.SCROLL_STEP = COMPONENTS.SETTINGS:getScrollStep()
    log('Initializing skin')
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
    COMPONENTS.STATUS:show(LOCALIZATION:get('status_initializing', 'Initializing'))
    SKIN:Bang(('[!SetVariable "ContextTitleSettings" "%s"]'):format(LOCALIZATION:get('main_context_title_settings', 'Settings')))
    SKIN:Bang(('[!SetVariable "ContextTitleOpenShortcutsFolder" "%s"]'):format(LOCALIZATION:get('main_context_title_open_shortcuts_folder', 'Open shortcuts folder')))
    SKIN:Bang(('[!SetVariable "ContextTitleExecuteStoppingBangs" "%s"]'):format(LOCALIZATION:get('main_context_title_execute_stopping_bangs', 'Execute stopping bangs')))
    SKIN:Bang(('[!SetVariable "ContextTitleHideGamesStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_start_hiding_games', 'Start hiding games')))
    SKIN:Bang(('[!SetVariable "ContextTitleUnhideGameStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_start_unhiding_games', 'Start unhiding games')))
    SKIN:Bang(('[!SetVariable "ContextTitleRemoveGamesStatus" "%s"]'):format(LOCALIZATION:get('main_context_title_start_removing_games', 'Start removing games')))
    COMPONENTS.TOOLBAR = require('main.toolbar')(COMPONENTS.SETTINGS)
    COMPONENTS.TOOLBAR:hide()
    COMPONENTS.ANIMATIONS = require('main.animations')()
    STATE.NUM_SLOTS = COMPONENTS.SETTINGS:getLayoutRows() * COMPONENTS.SETTINGS:getLayoutColumns()
    COMPONENTS.SLOTS = require('main.slots')(COMPONENTS.SETTINGS)
    COMPONENTS.LIBRARY = require('shared.library')(COMPONENTS.SETTINGS)
    COMPONENTS.PROCESS = require('main.process')()
    return detectGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Update = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    if STATE.SKIN_ANIMATION_PLAYING then
      return COMPONENTS.ANIMATIONS:play()
    elseif STATE.REVEALING_DELAY >= 0 and not STATE.SKIN_VISIBLE then
      STATE.REVEALING_DELAY = STATE.REVEALING_DELAY - 17
      if STATE.REVEALING_DELAY < 0 then
        return COMPONENTS.ANIMATIONS:pushSkinSlide(COMPONENTS.SETTINGS:getSkinSlideAnimation(), true)
      end
    else
      COMPONENTS.ANIMATIONS:play()
      if STATE.SCROLL_INDEX_UPDATED == false then
        updateSlots()
        STATE.SCROLL_INDEX_UPDATED = true
      end
    end
  end)
  if not (success) then
    COMPONENTS.STATUS:show(err, true)
    return setUpdateDivider(-1)
  end
end
UpdateProcess = function(running)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    return COMPONENTS.PROCESS:update(running == 1)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
UpdatePlatformProcesses = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    STATE.PLATFORM_RUNNING_STATUS = COMPONENTS.PROCESS:updatePlatforms()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
GameProcessStarted = function(game)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('Game started')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
GameProcessTerminated = function(game)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    local duration = COMPONENTS.PROCESS:getDuration() / 3600
    log(game:getTitle(), 'was played for', duration, 'hours')
    game:incrementHoursPlayed(duration)
    COMPONENTS.LIBRARY:save()
    local platformID = game:getPlatformID()
    if COMPONENTS.SETTINGS:getBangsEnabled() then
      if not (game:getIgnoresOtherBangs()) then
        local _list_0 = COMPONENTS.SETTINGS:getGlobalStoppingBangs()
        for _index_0 = 1, #_list_0 do
          local bang = _list_0[_index_0]
          SKIN:Bang(bang)
        end
        local platformBangs
        local _exp_0 = platformID
        if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getShortcutsStoppingBangs()
        elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 or ENUMS.PLATFORM_IDS.STEAM_SHORTCUTS == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getSteamStoppingBangs()
        elseif ENUMS.PLATFORM_IDS.BATTLENET == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getBattlenetStoppingBangs()
        elseif ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getGOGGalaxyStoppingBangs()
        else
          platformBangs = assert(nil, 'Encountered an unsupported platform ID when executing platform-specific stopping bangs.')
        end
        for _index_0 = 1, #platformBangs do
          local bang = platformBangs[_index_0]
          SKIN:Bang(bang)
        end
      end
      local _list_0 = game:getStoppingBangs()
      for _index_0 = 1, #_list_0 do
        local bang = _list_0[_index_0]
        SKIN:Bang(bang)
      end
    end
    local _exp_0 = platformID
    if ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
      if COMPONENTS.SETTINGS:getGOGGalaxyIndirectLaunch() then
        SKIN:Bang('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\closeClient.bat"]')
      end
    end
    if COMPONENTS.SETTINGS:getHideSkin() then
      return SKIN:Bang('[!ShowFade]')
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
ManuallyTerminateGameProcess = function()
  local success, err = pcall(function()
    return COMPONENTS.PROCESS:stopMonitoring()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
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
    if STATE.SKIN_VISIBLE and animationType ~= ENUMS.SKIN_ANIMATIONS.NONE and not otherWindowsActive() then
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
OnToolbarSearch = function(stack)
  if not (STATE.INITIALIZED) then
    return 
  end
  STATE.STACK_NEXT_FILTER = stack
  log('OnToolbarSearch', stack)
  return SKIN:Bang('[!ActivateConfig "#ROOTCONFIG#\\Search"]')
end
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
    return SKIN:Bang(('[!ActivateConfig "%s"]'):format(configName))
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
HandshakeSort = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\Sort"]'):format(COMPONENTS.SETTINGS:getSorting()))
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
    return SKIN:Bang(('[!ActivateConfig "%s"]'):format(configName))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
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
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%s, \'%s\')" "#ROOTCONFIG#\\Filter"]'):format(stack, appliedFilters))
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
local launchGame
launchGame = function(game)
  if game:isInstalled() == true then
    game:setLastPlayed(os.time())
    COMPONENTS.LIBRARY:sort(COMPONENTS.SETTINGS:getSorting())
    COMPONENTS.LIBRARY:save()
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    updateSlots()
    COMPONENTS.PROCESS:monitor(game)
    if COMPONENTS.SETTINGS:getBangsEnabled() then
      if not (game:getIgnoresOtherBangs()) then
        local _list_0 = COMPONENTS.SETTINGS:getGlobalStartingBangs()
        for _index_0 = 1, #_list_0 do
          local bang = _list_0[_index_0]
          SKIN:Bang(bang)
        end
        local platformBangs
        local _exp_0 = game:getPlatformID()
        if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getShortcutsStartingBangs()
        elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 or ENUMS.PLATFORM_IDS.STEAM_SHORTCUTS == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getSteamStartingBangs()
        elseif ENUMS.PLATFORM_IDS.BATTLENET == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getBattlenetStartingBangs()
        elseif ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getGOGGalaxyStartingBangs()
        else
          platformBangs = assert(nil, 'Encountered an unsupported platform ID when executing platform-specific starting bangs.')
        end
        for _index_0 = 1, #platformBangs do
          local bang = platformBangs[_index_0]
          SKIN:Bang(bang)
        end
      end
      local _list_0 = game:getStartingBangs()
      for _index_0 = 1, #_list_0 do
        local bang = _list_0[_index_0]
        SKIN:Bang(bang)
      end
    end
    SKIN:Bang(('[%s]'):format(game:getPath()))
    if COMPONENTS.SETTINGS:getHideSkin() then
      return SKIN:Bang('[!HideFade]')
    end
  elseif game:getPlatformID() == ENUMS.PLATFORM_IDS.STEAM then
    game:setLastPlayed(os.time())
    game:setInstalled(true)
    COMPONENTS.LIBRARY:sort(COMPONENTS.SETTINGS:getSorting())
    COMPONENTS.LIBRARY:save()
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    updateSlots()
    return SKIN:Bang(('[%s]'):format(game:getPath()))
  end
end
local hideGame
hideGame = function(game)
  if game:isVisible() == false then
    return 
  end
  game:setVisible(false)
  COMPONENTS.LIBRARY:save()
  local i = table.find(STATE.GAMES, game)
  table.remove(STATE.GAMES, i)
  if #STATE.GAMES == 0 then
    COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.NONE)
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    ToggleHideGames()
  end
  return updateSlots()
end
local unhideGame
unhideGame = function(game)
  if game:isVisible() == true then
    return 
  end
  game:setVisible(true)
  COMPONENTS.LIBRARY:save()
  local i = table.find(STATE.GAMES, game)
  table.remove(STATE.GAMES, i)
  if #STATE.GAMES == 0 then
    COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.NONE)
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    ToggleUnhideGames()
  end
  return updateSlots()
end
local removeGame
removeGame = function(game)
  local i = table.find(STATE.GAMES, game)
  table.remove(STATE.GAMES, i)
  COMPONENTS.LIBRARY:remove(game)
  i = table.find(STATE.GAMES, game)
  table.remove(STATE.GAMES, i)
  if #STATE.GAMES == 0 then
    COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.NONE)
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    ToggleRemoveGames()
  end
  return updateSlots()
end
OnLeftClickSlot = function(index)
  if not (STATE.INITIALIZED) then
    return 
  end
  if STATE.SKIN_ANIMATION_PLAYING then
    return 
  end
  if index < 1 or index > STATE.NUM_SLOTS then
    return 
  end
  local success, err = pcall(function()
    local game = COMPONENTS.SLOTS:leftClick(index)
    if not (game) then
      return 
    end
    local action
    local _exp_0 = STATE.LEFT_CLICK_ACTION
    if ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME == _exp_0 then
      action = launchGame
    elseif ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME == _exp_0 then
      action = hideGame
    elseif ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME == _exp_0 then
      action = unhideGame
    elseif ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME == _exp_0 then
      action = removeGame
    else
      action = assert(nil, 'main.init.OnLeftClickSlot')
    end
    local animationType = COMPONENTS.SETTINGS:getSlotsClickAnimation()
    if not (COMPONENTS.ANIMATIONS:pushSlotClick(index, animationType, action, game)) then
      return action(game)
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnMiddleClickSlot = function(index)
  if not (STATE.INITIALIZED) then
    return 
  end
  if STATE.SKIN_ANIMATION_PLAYING then
    return 
  end
  if index < 1 or index > STATE.NUM_SLOTS then
    return 
  end
  local success, err = pcall(function()
    log('OnMiddleClickSlot', index)
    local game = COMPONENTS.SLOTS:middleClick(index)
    if game == nil then
      return 
    end
    local configName = ('%s\\Game'):format(STATE.ROOT_CONFIG)
    if STATE.GAME_BEING_MODIFIED ~= nil and game == STATE.GAME_BEING_MODIFIED then
      STATE.GAME_BEING_MODIFIED = nil
      return SKIN:Bang(('[!DeactivateConfig "%s"]'):format(configName))
    end
    STATE.GAME_BEING_MODIFIED = game
    local config = utility.getConfig(configName)
    if config == nil or not config:isActive() then
      return SKIN:Bang(('[!ActivateConfig "%s"]'):format(configName))
    else
      return HandshakeGame()
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
HandshakeGame = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('HandshakeGame')
    local gameID = STATE.GAME_BEING_MODIFIED:getGameID()
    STATE.GAME_BEING_MODIFIED = nil
    assert(gameID ~= nil, 'main.init.HandshakeGame')
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\Game"]'):format(gameID))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
UpdateGame = function(gameID)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('UpdateGame')
    if gameID ~= nil then
      local games = io.readJSON(STATE.PATHS.GAMES)
      games = games.games
      local game = games[gameID]
      if game == nil or game.gameID ~= gameID then
        game = nil
        for _index_0 = 1, #games do
          local args = games[_index_0]
          if args.gameID == gameID then
            game = args
            break
          end
        end
      end
      assert(game ~= nil, 'main.init.UpdateGame')
      return COMPONENTS.LIBRARY:update(Game(game))
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnHoverSlot = function(index)
  if not (STATE.INITIALIZED) then
    return 
  end
  if STATE.SKIN_ANIMATION_PLAYING then
    return 
  end
  if index < 1 or index > STATE.NUM_SLOTS then
    return 
  end
  local success, err = pcall(function()
    return COMPONENTS.SLOTS:hover(index)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnLeaveSlot = function(index)
  if not (STATE.INITIALIZED) then
    return 
  end
  if STATE.SKIN_ANIMATION_PLAYING then
    return 
  end
  if index < 1 or index > STATE.NUM_SLOTS then
    return 
  end
  local success, err = pcall(function()
    return COMPONENTS.SLOTS:leave(index)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnScrollSlots = function(direction)
  if not (STATE.INITIALIZED) then
    return 
  end
  if STATE.SKIN_ANIMATION_PLAYING then
    return 
  end
  local success, err = pcall(function()
    local index = STATE.SCROLL_INDEX + direction * STATE.SCROLL_STEP
    if index < 1 then
      return 
    elseif index > #STATE.GAMES - STATE.NUM_SLOTS + 1 then
      return 
    end
    STATE.SCROLL_INDEX = index
    log(('Scroll index is now %d'):format(STATE.SCROLL_INDEX))
    STATE.SCROLL_INDEX_UPDATED = false
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnFinishedDetectingPlatformGames = function()
  local success, err = pcall(function()
    log('Finished detecting platform\'s games')
    local platform = table.remove(STATE.PLATFORM_QUEUE, 1)
    local games = platform:getGames()
    log(('Found %d %s games'):format(#games, platform:getName()))
    COMPONENTS.LIBRARY:add(games)
    for _index_0 = 1, #games do
      local game = games[_index_0]
      if game:getBannerURL() ~= nil then
        if game:getBanner() == nil then
          game:setBannerURL(nil)
        else
          table.insert(STATE.BANNER_QUEUE, game)
        end
      end
    end
    if #STATE.PLATFORM_QUEUE > 0 then
      return startDetectingPlatformGames()
    end
    STATE.PLATFORM_QUEUE = nil
    log(('%d banners to download'):format(#STATE.BANNER_QUEUE))
    if #STATE.BANNER_QUEUE > 0 then
      return startDownloadingBanner()
    end
    return onInitialized()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnParsedShortcuts = function()
  local success, err = pcall(function()
    if not (STATE.PLATFORM_QUEUE[1]:hasParsedShortcuts()) then
      return utility.runLastCommand()
    end
    log('Parsed Windows shortcuts')
    local output = ''
    local path = STATE.PLATFORM_QUEUE[1]:getOutputPath()
    if io.fileExists(path) then
      output = io.readFile(path)
    end
    STATE.PLATFORM_QUEUE[1]:generateGames(output)
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnCommunityProfileDownloaded = function()
  local success, err = pcall(function()
    log('Successfully downloaded Steam community profile')
    stopDownloader()
    local downloadedPath = STATE.PLATFORM_QUEUE[1]:getDownloadedCommunityProfilePath()
    local cachedPath = STATE.PLATFORM_QUEUE[1]:getCachedCommunityProfilePath()
    os.rename(downloadedPath, cachedPath)
    local profile = ''
    if io.fileExists(cachedPath, false) then
      profile = io.readFile(cachedPath, false)
    end
    STATE.PLATFORM_QUEUE[1]:parseCommunityProfile(profile)
    STATE.PLATFORM_QUEUE[1]:getLibraries()
    if STATE.PLATFORM_QUEUE[1]:hasLibrariesToParse() then
      return utility.runCommand(STATE.PLATFORM_QUEUE[1]:getACFs())
    end
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnCommunityProfileDownloadFailed = function()
  local success, err = pcall(function()
    log('Failed to download Steam community profile')
    stopDownloader()
    STATE.PLATFORM_QUEUE[1]:getLibraries()
    if STATE.PLATFORM_QUEUE[1]:hasLibrariesToParse() then
      return utility.runCommand(STATE.PLATFORM_QUEUE[1]:getACFs())
    end
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnGotACFs = function()
  local success, err = pcall(function()
    if not (STATE.PLATFORM_QUEUE[1]:hasGottenACFs()) then
      return utility.runLastCommand()
    end
    log('Dumped list of Steam appmanifests')
    STATE.PLATFORM_QUEUE[1]:generateGames()
    if STATE.PLATFORM_QUEUE[1]:hasLibrariesToParse() then
      return utility.runCommand(STATE.PLATFORM_QUEUE[1]:getACFs())
    end
    STATE.PLATFORM_QUEUE[1]:generateShortcuts()
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnIdentifiedBattlenetFolders = function()
  local success, err = pcall(function()
    if not (STATE.PLATFORM_QUEUE[1]:hasProcessedPath()) then
      return utility.runLastCommand()
    end
    log('Dumped list of folders in a Blizzard Battle.net folder')
    STATE.PLATFORM_QUEUE[1]:generateGames(io.readFile(io.joinPaths(STATE.PLATFORM_QUEUE[1]:getCachePath(), 'output.txt')))
    if STATE.PLATFORM_QUEUE[1]:hasUnprocessedPaths() then
      return utility.runCommand(STATE.PLATFORM_QUEUE[1]:identifyFolders())
    end
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnDumpedDBs = function()
  local success, err = pcall(function()
    if not (STATE.PLATFORM_QUEUE[1]:hasDumpedDatabases()) then
      return utility.runLastCommand()
    end
    log('Dumped GOG Galaxy databases')
    local cachePath = STATE.PLATFORM_QUEUE[1]:getCachePath()
    local index = io.readFile(io.joinPaths(cachePath, 'index.txt'))
    local galaxy = io.readFile(io.joinPaths(cachePath, 'galaxy.txt'))
    STATE.PLATFORM_QUEUE[1]:generateGames(index, galaxy)
    return OnFinishedDetectingPlatformGames()
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
    stopDownloader()
    return onInitialized()
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
