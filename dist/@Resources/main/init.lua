RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
local json = nil
local Game = nil
LOCALIZATION = nil
STATE = {
  GAMES = { },
  INITIALIZED = false,
  LEFT_CLICK_ACTION = 1,
  NUM_SLOTS = 0,
  PATHS = {
    GAMES = 'games.json'
  },
  PLATFORM_NAMES = { },
  REVEALING_DELAY = 0,
  ROOT_CONFIG = nil,
  SCROLL_INDEX = 1,
  SCROLL_INDEX_UPDATED = nil,
  SCROLL_STEP = 1,
  SETTINGS = { },
  SKIN_ANIMATION_PLAYING = false,
  SKIN_VISIBLE = true,
  SLOT_CLICK_ANIMATION = nil,
  SLOT_HOVER_ANIMATION = nil,
  SKIN_SLIDE_ANIMATION = nil,
  BANNER_QUEUE = nil,
  GAME_BEING_MODIFIED = nil,
  PLATFORM_ENABLED_STATUS = nil,
  PLATFORM_QUEUE = nil
}
COMPONENTS = {
  ANIMATIONS = nil,
  COMMANDER = nil,
  CONTEXT_MENU = nil,
  DOWNLOADER = nil,
  LIBRARY = nil,
  PROCESS = nil,
  SETTINGS = nil,
  SIGNAL = nil,
  SLOTS = nil,
  STATUS = nil,
  TOOLBAR = nil
}
SIGNALS = {
  DETECTED_BATTLENET_GAMES = 'detected_battlenet_games',
  DETECTED_GOG_GALAXY_GAMES = 'detected_gog_galaxy_games',
  DETECTED_SHORTCUT_GAMES = 'detected_shortcut_games',
  DETECTED_STEAM_GAMES = 'detected_steam_games',
  DOWNLOADED_GOG_GALAXY_COMMUNITY_PROFILE = 'downloaded_gog_galaxy_community_profile',
  GAME_PROCESS_TERMINATED = 'game_process_terminated',
  OPEN_FILTERING_MENU = 'open_filtering_menu',
  OPEN_SEARCH_MENU = 'open_search_menu',
  OPEN_SORTING_MENU = 'open_sort_menu',
  REVERSE_GAMES = 'reverse_games',
  START_HIDING_GAMES = 'start_hiding_games',
  START_REMOVING_GAMES = 'start_removing_games',
  START_UNHIDING_GAMES = 'start_unhiding_games',
  STOP_HIDING_GAMES = 'stop_hiding_games',
  STOP_REMOVING_GAMES = 'stop_removing_games',
  STOP_UNHIDING_GAMES = 'stop_unhiding_games',
  UPDATE_GAMES = 'update_games',
  UPDATE_PLATFORM_RUNNING_STATUS = 'update_platform_running_status',
  UPDATE_SLOTS = 'update_slots'
}
log = function(...)
  if STATE.LOGGING == true then
    return print(...)
  end
end
HideStatus = function()
  return COMPONENTS.STATUS:hide()
end
setUpdateDivider = function(value)
  assert(type(value) == 'number' and value % 1 == 0 and value ~= 0, 'main.init.setUpdateDivider')
  SKIN:Bang(('[!SetOption "Script" "UpdateDivider" "%d"]'):format(value))
  return SKIN:Bang('[!UpdateMeasure "Script"]')
end
local startDetectingPlatformGames
startDetectingPlatformGames = function()
  local platform = STATE.PLATFORM_QUEUE[1]
  local msg = LOCALIZATION:get('main_status_detecting_platform_games', 'Detecting %s games')
  COMPONENTS.STATUS:show(msg:format(platform:getName()))
  local _exp_0 = platform:getPlatformID()
  if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
    COMPONENTS.SIGNAL:register(SIGNALS.DETECTED_SHORTCUT_GAMES, platform:onParsedShortcuts())
    return platform:parseShortcuts()
  elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 then
    log('Starting to detect Steam games')
    COMPONENTS.SIGNAL:register(SIGNALS.DETECTED_STEAM_GAMES, platform:onGotACFs())
    local processLocalFiles
    processLocalFiles = function()
      platform:getLibraries()
      if platform:hasLibrariesToParse() then
        return platform:getACFs()
      end
      return OnFinishedDetectingPlatformGames()
    end
    local url, folder, file = platform:downloadCommunityProfile()
    if url ~= nil then
      log('Attempting to download and parse the Steam community profile')
      COMPONENTS.DOWNLOADER:push({
        url = url,
        outputFile = file,
        outputFolder = folder,
        finishCallback = function()
          log('Successfully downloaded Steam community profile')
          local cachedPath = io.joinPaths(folder, file)
          local profile = ''
          if io.fileExists(cachedPath) then
            profile = io.readFile(cachedPath)
          end
          platform:parseCommunityProfile(profile)
          return processLocalFiles()
        end,
        errorCallback = function()
          log('Failed to download Steam community profile')
          return processLocalFiles()
        end
      })
      return COMPONENTS.DOWNLOADER:start()
    else
      return processLocalFiles()
    end
  elseif ENUMS.PLATFORM_IDS.BATTLENET == _exp_0 then
    log('Starting to detect Blizzard Battle.net games')
    if platform:hasUnprocessedPaths() then
      COMPONENTS.SIGNAL:register(SIGNALS.DETECTED_BATTLENET_GAMES, platform:onProcessedPath())
      return platform:identifyFolders()
    else
      return OnFinishedDetectingPlatformGames()
    end
  elseif ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
    log('Starting to detect GOG Galaxy games')
    COMPONENTS.SIGNAL:register(SIGNALS.DETECTED_GOG_GALAXY_GAMES, platform:onDumpedDatabases())
    COMPONENTS.SIGNAL:register(SIGNALS.DOWNLOADED_GOG_GALAXY_COMMUNITY_PROFILE, platform:onCommunityProfileDownloaded())
    if not (platform:downloadCommunityProfile()) then
      COMPONENTS.SIGNAL:clear(SIGNALS.DOWNLOADED_GOG_GALAXY_COMMUNITY_PROFILE)
      return platform:dumpDatabases()
    end
  elseif ENUMS.PLATFORM_IDS.CUSTOM == _exp_0 then
    log('Starting to detect Custom games')
    platform:detectBanners(COMPONENTS.LIBRARY:getOldGames())
    return OnFinishedDetectingPlatformGames()
  else
    return assert(nil, 'main.init.startDetectingPlatformGames')
  end
end
local detectPlatforms
detectPlatforms = function()
  COMPONENTS.STATUS:show(LOCALIZATION:get('main_status_detecting_platforms', 'Detecting platforms'))
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
  local platformRunningStatus = { }
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
      platformRunningStatus[platformID] = false
    end
    if enabled then
      table.insert(STATE.PLATFORM_QUEUE, platform)
    end
    log(' ' .. STATE.PLATFORM_NAMES[platformID] .. ' = ' .. tostring(enabled))
  end
  COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_PLATFORM_RUNNING_STATUS, platformRunningStatus)
  return assert(#STATE.PLATFORM_QUEUE > 0, 'There are no enabled platforms.')
end
local detectGames
detectGames = function()
  COMPONENTS.STATUS:show(LOCALIZATION:get('main_status_detecting_games', 'Detecting games'))
  STATE.BANNER_QUEUE = { }
  return startDetectingPlatformGames()
end
local updateGames
updateGames = function(games)
  STATE.GAMES = games
  STATE.SCROLL_INDEX = 1
  return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
end
local updateSlots
updateSlots = function()
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
end
local onInitialized
onInitialized = function()
  COMPONENTS.STATUS:hide()
  COMPONENTS.LIBRARY:finalize(STATE.PLATFORM_ENABLED_STATUS)
  STATE.PLATFORM_ENABLED_STATUS = nil
  COMPONENTS.LIBRARY:save()
  COMPONENTS.LIBRARY:sort(COMPONENTS.SETTINGS:getSorting())
  STATE.GAMES = COMPONENTS.LIBRARY:get()
  COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
  STATE.INITIALIZED = true
  if STATE.SKIN_SLIDE_ANIMATION ~= ENUMS.SKIN_ANIMATIONS.NONE then
    COMPONENTS.ANIMATIONS:pushSkinSlide(STATE.SKIN_SLIDE_ANIMATION, false)
    setUpdateDivider(1)
  end
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
local gameProcessTerminated
gameProcessTerminated = function(game, duration)
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
      elseif ENUMS.PLATFORM_IDS.CUSTOM == _exp_0 then
        platformBangs = COMPONENTS.SETTINGS:getCustomStoppingBangs()
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
    SKIN:Bang('[!ShowFade]')
  end
  if COMPONENTS.SETTINGS:getShowSession() then
    return SKIN:Bang(('[!DeactivateConfig "%s"]'):format(('%s\\Session'):format(STATE.ROOT_CONFIG)))
  end
end
local openSearchMenu
openSearchMenu = function(stack)
  STATE.STACK_NEXT_FILTER = stack
  return SKIN:Bang('[!ActivateConfig "#ROOTCONFIG#\\Search"]')
end
HandshakeSearch = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    local args = tostring(STATE.STACK_NEXT_FILTER)
    local bang = ('[!CommandMeasure "Script" "Handshake(%s)" "#ROOTCONFIG#\\Search"]'):format(args)
    return SKIN:Bang(bang)
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
    return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_GAMES, COMPONENTS.LIBRARY:get())
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local openSortingMenu
openSortingMenu = function(quick)
  if quick then
    local sortingType
    local _exp_0 = COMPONENTS.SETTINGS:getSorting()
    if ENUMS.SORTING_TYPES.ALPHABETICALLY == _exp_0 then
      sortingType = ENUMS.SORTING_TYPES.LAST_PLAYED
    elseif ENUMS.SORTING_TYPES.LAST_PLAYED == _exp_0 then
      sortingType = ENUMS.SORTING_TYPES.HOURS_PLAYED
    elseif ENUMS.SORTING_TYPES.HOURS_PLAYED == _exp_0 then
      sortingType = ENUMS.SORTING_TYPES.ALPHABETICALLY
    else
      sortingType = ENUMS.SORTING_TYPES.ALPHABETICALLY
    end
    return Sort(sortingType)
  end
  local configName = ('%s\\Sort'):format(STATE.ROOT_CONFIG)
  local config = RAINMETER:GetConfig(configName)
  if config ~= nil and config:isActive() then
    return SKIN:Bang(('[!DeactivateConfig "%s"]'):format(configName))
  end
  return SKIN:Bang(('[!ActivateConfig "%s"]'):format(configName))
end
HandshakeSort = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    local args = COMPONENTS.SETTINGS:getSorting()
    local bang = ('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\Sort"]'):format(args)
    return SKIN:Bang(bang)
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
    return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_GAMES, STATE.GAMES)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local reverseGames
reverseGames = function()
  table.reverse(STATE.GAMES)
  return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
end
local openFilteringMenu
openFilteringMenu = function(stack)
  STATE.STACK_NEXT_FILTER = stack
  local configName = ('%s\\Filter'):format(STATE.ROOT_CONFIG)
  local config = RAINMETER:GetConfig(configName)
  if config ~= nil and config:isActive() then
    return HandshakeFilter()
  end
  return SKIN:Bang(('[!ActivateConfig "%s"]'):format(configName))
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
    local args = ('%s, \'%s\''):format(stack, appliedFilters)
    local bang = ('[!CommandMeasure "Script" "Handshake(%s)" "#ROOTCONFIG#\\Filter"]'):format(args)
    return SKIN:Bang(bang)
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
    return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_GAMES, COMPONENTS.LIBRARY:get())
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Initialize = function()
  STATE.ROOT_CONFIG = SKIN:GetVariable('ROOTCONFIG')
  dofile(('%s%s'):format(SKIN:GetVariable('@'), 'lib\\rainmeter_helpers.lua'))
  COMPONENTS.STATUS = require('shared.status')()
  local success, err = pcall(function()
    require('shared.string')
    json = require('lib.json')
    require('shared.io')(json)
    require('shared.rainmeter')
    require('shared.enums')
    additionalEnums()
    Game = require('main.game')
    COMPONENTS.DOWNLOADER = require('shared.downloader')()
    COMPONENTS.COMMANDER = require('shared.commander')()
    COMPONENTS.SIGNAL = require('shared.signal')()
    COMPONENTS.SIGNAL:register(SIGNALS.UPDATE_GAMES, updateGames)
    COMPONENTS.SIGNAL:register(SIGNALS.UPDATE_SLOTS, updateSlots)
    COMPONENTS.SIGNAL:register(SIGNALS.GAME_PROCESS_TERMINATED, gameProcessTerminated)
    COMPONENTS.SIGNAL:register(SIGNALS.OPEN_SEARCH_MENU, openSearchMenu)
    COMPONENTS.SIGNAL:register(SIGNALS.OPEN_SORTING_MENU, openSortingMenu)
    COMPONENTS.SIGNAL:register(SIGNALS.OPEN_FILTERING_MENU, openFilteringMenu)
    COMPONENTS.SIGNAL:register(SIGNALS.REVERSE_GAMES, reverseGames)
    COMPONENTS.SETTINGS = require('shared.settings')()
    STATE.LOGGING = COMPONENTS.SETTINGS:getLogging()
    STATE.SLOT_CLICK_ANIMATION = COMPONENTS.SETTINGS:getSlotsClickAnimation()
    STATE.SLOT_HOVER_ANIMATION = COMPONENTS.SETTINGS:getSlotsHoverAnimation()
    STATE.SKIN_SLIDE_ANIMATION = COMPONENTS.SETTINGS:getSkinSlideAnimation()
    STATE.SCROLL_STEP = COMPONENTS.SETTINGS:getScrollStep()
    log('Initializing skin')
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
    COMPONENTS.CONTEXT_MENU = require('main.context_menu')()
    COMPONENTS.STATUS:show(LOCALIZATION:get('status_initializing', 'Initializing'))
    COMPONENTS.TOOLBAR = require('main.toolbar')(COMPONENTS.SETTINGS)
    COMPONENTS.TOOLBAR:hide()
    COMPONENTS.ANIMATIONS = require('main.animations')()
    STATE.NUM_SLOTS = COMPONENTS.SETTINGS:getLayoutRows() * COMPONENTS.SETTINGS:getLayoutColumns()
    COMPONENTS.SLOTS = require('main.slots')(COMPONENTS.SETTINGS)
    COMPONENTS.PROCESS = require('main.process')()
    COMPONENTS.LIBRARY = require('shared.library')(COMPONENTS.SETTINGS)
    detectPlatforms()
    if COMPONENTS.LIBRARY:getDetectGames() == true then
      return detectGames()
    else
      return onInitialized()
    end
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
        return COMPONENTS.ANIMATIONS:pushSkinSlide(STATE.SKIN_SLIDE_ANIMATION, true)
      end
    else
      COMPONENTS.ANIMATIONS:play()
      if STATE.SCROLL_INDEX_UPDATED == false then
        COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
        STATE.SCROLL_INDEX_UPDATED = true
      end
    end
  end)
  if not (success) then
    COMPONENTS.STATUS:show(err, true)
    return setUpdateDivider(-1)
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
  local configs = RAINMETER:GetConfigs((function()
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
    if STATE.SKIN_VISIBLE and STATE.SKIN_SLIDE_ANIMATION ~= ENUMS.SKIN_ANIMATIONS.NONE and not otherWindowsActive() then
      if COMPONENTS.ANIMATIONS:pushSkinSlide(STATE.SKIN_SLIDE_ANIMATION, false) then
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
HandshakeGame = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('HandshakeGame')
    local gameID = STATE.GAME_BEING_MODIFIED:getGameID()
    assert(gameID ~= nil, 'main.init.HandshakeGame')
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\Game"]'):format(gameID))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local getGameByID
getGameByID = function(gameID)
  assert(type(gameID) == 'number' and gameID % 1 == 0, 'main.init.getGameByID')
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
  if game == nil then
    log('Failed to get game by gameID:', gameID)
    return nil
  end
  return Game(game)
end
UpdateGame = function(gameID)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('UpdateGame', gameID)
    local game = getGameByID(gameID)
    assert(game ~= nil, 'main.init.UpdateGame')
    COMPONENTS.LIBRARY:update(game)
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
    COMPONENTS.LIBRARY:extend(games)
    for _index_0 = 1, #games do
      local game = games[_index_0]
      if game:getBannerURL() ~= nil then
        local path = game:getBanner()
        if path == nil then
          game:setBannerURL(nil)
        elseif not io.fileExists((path:gsub('%..+', '%.failedToDownload'))) then
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
      local finishCallback
      finishCallback = function(args)
        COMPONENTS.STATUS:show(LOCALIZATION:get('main_status_n_banners_to_download', '%d banners left to download'):format(args.bannersLeft))
        args.game:setBannerURL(nil)
        return args.game:setExpectedBanner(nil)
      end
      local finalFinishCallback
      finalFinishCallback = function(args)
        finishCallback(args)
        return onInitialized()
      end
      local errorCallback
      errorCallback = function(args)
        local file = args.file:reverse():match('^[^%.]+%.([^\\]+)'):reverse()
        io.writeFile(io.joinPaths(args.folder, file .. '.failedToDownload'), '')
        args.game:setBanner(nil)
        return args.game:setBannerURL(nil)
      end
      for i, game in ipairs(STATE.BANNER_QUEUE) do
        local folder, file = io.splitPath(game:getBanner())
        COMPONENTS.DOWNLOADER:push({
          url = game:getBannerURL(),
          outputFile = file,
          outputFolder = folder,
          finishCallback = (function()
            if i > 1 then
              return finishCallback
            else
              return finalFinishCallback
            end
          end)(),
          errorCallback = errorCallback,
          callbackArgs = {
            file = file,
            folder = folder,
            game = game,
            bannersLeft = i
          }
        })
      end
      if COMPONENTS.DOWNLOADER:start() then
        return 
      end
    end
    return onInitialized()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local getPlatformByGame
getPlatformByGame = function(game)
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
  local platformID = game:getPlatformID()
  for _index_0 = 1, #platforms do
    local platform = platforms[_index_0]
    if platform:getPlatformID() == platformID then
      return platform
    end
  end
  log("Failed to get platform based on the game", platformID)
  return nil
end
ReacquireBanner = function(gameID)
  local success, err = pcall(function()
    log('ReacquireBanner', gameID)
    local game = getGameByID(gameID)
    assert(game ~= nil, 'main.init.OnReacquireBanner')
    log('Reacquiring a banner for', game:getTitle())
    local platform = getPlatformByGame(game)
    assert(platform ~= nil, 'main.init.ReacquireBanner')
    local url = platform:getBannerURL(game)
    if url == nil then
      log("Failed to get URL for banner reacquisition", gameID)
      return 
    end
    local path = game:getBanner()
    if io.fileExists(path) then
      os.remove(io.absolutePath(path))
    end
    local folder, file = io.splitPath(path)
    COMPONENTS.DOWNLOADER:push({
      url = url,
      outputFile = file,
      outputFolder = folder,
      finishCallback = function()
        log('Successfully reacquired a banner')
        STATE.SCROLL_INDEX_UPDATED = false
        SKIN:Bang('[!UpdateMeasure "Script"]')
        return SKIN:Bang('[!CommandMeasure "Script" "OnReacquiredBanner()" "#ROOTCONFIG#\\Game"]')
      end,
      errorCallback = function()
        return log('Failed to reacquire a banner')
      end
    })
    return COMPONENTS.DOWNLOADER:start()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OpenStorePage = function(gameID)
  local success, err = pcall(function()
    local game = getGameByID(gameID)
    assert(game ~= nil, 'main.init.OpenStorePage')
    local platform = getPlatformByGame(game)
    assert(platform ~= nil, 'main.init.OpenStorePage')
    local url = platform:getStorePageURL(game)
    if url == nil then
      log("Failed to get URL for opening the store page", gameID)
      return 
    end
    return SKIN:Bang(('[%s]'):format(url))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
HandshakeNewGame = function()
  local success, err = pcall(function()
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\NewGame"]'):format(COMPONENTS.LIBRARY:getNextAvailableGameID()))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnAddGame = function(gameID)
  local success, err = pcall(function()
    local game = getGameByID(gameID)
    assert(game ~= nil, 'main.init.OnAddGame')
    return COMPONENTS.LIBRARY:insert(game)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
