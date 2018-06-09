RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
utility = nil
json = nil
Game = nil
LOCALIZATION = nil
STATE = {
  INITIALIZED = false,
  PATHS = {
    RESOURCES = nil,
    DOWNLOADFILE = nil,
    GAMES = 'wishlist.json'
  },
  ROOT_CONFIG = nil,
  SETTINGS = { },
  NUM_SLOTS = 0,
  SCROLL_INDEX = 1,
  SCROLL_STEP = 1,
  SCROLL_INDEX_UPDATED = nil,
  LEFT_CLICK_ACTION = 1,
  PLATFORM_NAMES = { },
  PLATFORM_RUNNING_STATUS = { },
  GAMES = { },
  REVEALING_DELAY = 0,
  SKIN_VISIBLE = true,
  SKIN_ANIMATION_PLAYING = false,
  VARIANT = 'Wishlist',
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
startDetectingPlatformGames = function()
  COMPONENTS.STATUS:show(LOCALIZATION:get('main_status_detecting_platform_games', 'Detecting %s games'):format(STATE.PLATFORM_QUEUE[1]:getName()))
  local _exp_0 = STATE.PLATFORM_QUEUE[1]:getPlatformID()
  if ENUMS.PLATFORM_IDS.STEAM == _exp_0 or ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
    local url, path, success, failure = STATE.PLATFORM_QUEUE[1]:getWishlistURL()
    return utility.downloadFile(url, path, success, failure)
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
    local _list_0 = require('wishlist.platforms')
    for _index_0 = 1, #_list_0 do
      local Platform = _list_0[_index_0]
      _accum_0[_len_0] = Platform(COMPONENTS.SETTINGS)
      _len_0 = _len_0 + 1
    end
    platforms = _accum_0
  end
  log('Num platforms:', #platforms)
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
  return assert(#STATE.PLATFORM_QUEUE > 0, 'There are no enabled platforms.')
end
local detectGames
detectGames = function()
  COMPONENTS.STATUS:show(LOCALIZATION:get('main_status_detecting_games', 'Detecting games'))
  STATE.BANNER_QUEUE = { }
  return startDetectingPlatformGames()
end
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
    return utility.downloadBanner(STATE.BANNER_QUEUE[1])
  else
    STATE.BANNER_QUEUE = nil
    return OnFinishedDownloadingBanners()
  end
end
onInitialized = function()
  COMPONENTS.STATUS:hide()
  COMPONENTS.LIBRARY:finalize(STATE.PLATFORM_ENABLED_STATUS)
  STATE.PLATFORM_ENABLED_STATUS = nil
  COMPONENTS.LIBRARY:save()
  COMPONENTS.LIBRARY:sort(COMPONENTS.SETTINGS:getSorting())
  STATE.GAMES = COMPONENTS.LIBRARY:get()
  updateSlots()
  STATE.INITIALIZED = true
  return log('Skin initialized')
end
local additionalEnums
additionalEnums = function()
  ENUMS.LEFT_CLICK_ACTIONS = {
    OPEN_STORE_PAGE = 1
  }
end
local updateContextTitles
updateContextTitles = function()
  SKIN:Bang(('[!SetVariable "ContextTitleSettings" "%s"]'):format(LOCALIZATION:get('main_context_title_settings', 'Settings')))
  return SKIN:Bang(('[!SetVariable "ContextTitleRefresh" "%s"]'):format(LOCALIZATION:get('wishlist_context_title_refresh', 'Refresh wishlist')))
end
Initialize = function()
  STATE.PATHS.RESOURCES = SKIN:GetVariable('@')
  STATE.PATHS.DOWNLOADFILE = SKIN:GetVariable('CURRENTPATH') .. 'DownloadFile\\'
  STATE.ROOT_CONFIG = SKIN:GetVariable('ROOTCONFIG')
  dofile(('%s%s'):format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
  COMPONENTS.STATUS = require('shared.status')()
  local success, err = pcall(function()
    require('shared.enums')
    require('wishlist.events')
    additionalEnums()
    Game = require('wishlist.game')
    utility = require('shared.utility')
    utility.createJSONHelpers()
    json = require('lib.json')
    COMPONENTS.SETTINGS = require('shared.settings')()
    STATE.LOGGING = COMPONENTS.SETTINGS:getLogging()
    STATE.SCROLL_STEP = COMPONENTS.SETTINGS:getScrollStep()
    log('Initializing skin')
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
    updateContextTitles()
    COMPONENTS.STATUS:show(LOCALIZATION:get('status_initializing', 'Initializing'))
    COMPONENTS.TOOLBAR = require('main.toolbar')(COMPONENTS.SETTINGS)
    COMPONENTS.TOOLBAR:hide()
    COMPONENTS.ANIMATIONS = require('main.animations')()
    STATE.NUM_SLOTS = COMPONENTS.SETTINGS:getLayoutRows() * COMPONENTS.SETTINGS:getLayoutColumns()
    COMPONENTS.SLOTS = require('main.slots')(COMPONENTS.SETTINGS, require('main.slots.slot'), require('wishlist.slots.overlay_slot'))
    COMPONENTS.PROCESS = require('wishlist.process')()
    COMPONENTS.LIBRARY = require('shared.library')(COMPONENTS.SETTINGS, STATE.PATHS.GAMES)
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
