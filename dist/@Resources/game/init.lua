RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
local utility = nil
LOCALIZATION = nil
STATE = {
  PATHS = {
    GAMES = 'games.json',
    BANGS = 'cache\\bangs.txt',
    NOTES = 'cache\\notes.txt'
  },
  SCROLLBAR = {
    START = nil,
    MAX_HEIGHT = nil,
    HEIGHT = nil,
    STEP = nil
  },
  GAME = nil,
  ALL_GAMES = nil,
  GAMES_VERSION = nil,
  ALL_TAGS = nil,
  ALL_PLATFORMS = nil,
  HIGHLIGHTED_SLOT_INDEX = 0,
  CENTERED = false,
  ACTIVE_INPUT = false
}
local COMPONENTS = {
  STATUS = nil,
  SETTINGS = nil,
  SLOTS = nil
}
local Property
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, args)
      self.title = args.title
      self.value = args.value
      self.action = args.action
      self.update = args.update
    end,
    __base = _base_0,
    __name = "Property"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Property = _class_0
end
local Slot
do
  local _class_0
  local _base_0 = {
    populate = function(self, property)
      self.property = property
      return self:update()
    end,
    update = function(self)
      if self.property ~= nil then
        if self.property.update ~= nil then
          self.property.value = self.property:update()
        end
        SKIN:Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]'):format(self.index, utility.replaceUnsupportedChars(self.property.title)))
        local value = utility.replaceUnsupportedChars(self.property.value)
        SKIN:Bang(('[!SetOption "Slot%dValue" "Text" "%s"]'):format(self.index, value))
        if value:len() > self.maxValueStringLength then
          SKIN:Bang(('[!SetOption "Slot%dValue" "ToolTipText" "%s"]'):format(self.index, value))
          SKIN:Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "0"]'):format(self.index))
        else
          SKIN:Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "1"]'):format(self.index))
        end
        return 
      end
      SKIN:Bang(('[!SetOption "Slot%dTitle" "Text" " "]'):format(self.index))
      SKIN:Bang(('[!SetOption "Slot%dValue" "Text" " "]'):format(self.index))
      return SKIN:Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "1"]'):format(self.index))
    end,
    hasAction = function(self)
      return self.property ~= nil and self.property.action ~= nil
    end,
    action = function(self)
      if self.property == nil or self.property.action == nil then
        return 
      end
      return self.property:action(self.index)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, index, maxValueStringLength)
      self.index = index
      self.maxValueStringLength = maxValueStringLength
    end,
    __base = _base_0,
    __name = "Slot"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Slot = _class_0
end
local Game = nil
HideStatus = function()
  return COMPONENTS.STATUS:hide()
end
local additionalEnums
additionalEnums = function()
  ENUMS.TAG_STATES = {
    DISABLED = 1,
    ENABLED = 2,
    ENABLED_PLATFORM = 3,
    MAX = 4
  }
end
local getGamesAndTags
getGamesAndTags = function()
  local games = io.readJSON(STATE.PATHS.GAMES)
  STATE.GAMES_VERSION = games.version
  STATE.TAGS_DICTIONARY = games.tagsDictionary
  STATE.GAMES_UPDATED_TIMESTAMP = games.updated or os.date('*t')
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = games.games
    for _index_0 = 1, #_list_0 do
      local args = _list_0[_index_0]
      _accum_0[_len_0] = Game(args, STATE.TAGS_DICTIONARY)
      _len_0 = _len_0 + 1
    end
    STATE.ALL_GAMES = _accum_0
  end
  STATE.ALL_TAGS = { }
  for key, tag in pairs(STATE.TAGS_DICTIONARY) do
    STATE.ALL_TAGS[tag] = ENUMS.TAG_STATES.DISABLED
  end
end
Initialize = function()
  SKIN:Bang('[!Hide]')
  STATE.PATHS.RESOURCES = SKIN:GetVariable('@')
  dofile(('%s%s'):format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
  COMPONENTS.STATUS = require('shared.status')()
  local success, err = pcall(function()
    require('shared.enums')
    additionalEnums()
    utility = require('shared.utility')
    utility.createJSONHelpers()
    COMPONENTS.SETTINGS = require('shared.settings')()
    if COMPONENTS.SETTINGS:getLogging() == true then
      log = function(...)
        return print(...)
      end
    else
      log = function() end
    end
    log('Initializing Game config')
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
    Game = require('main.game')
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = require('main.platforms')
      for _index_0 = 1, #_list_0 do
        local Platform = _list_0[_index_0]
        _accum_0[_len_0] = Platform(COMPONENTS.SETTINGS)
        _len_0 = _len_0 + 1
      end
      STATE.ALL_PLATFORMS = _accum_0
    end
    getGamesAndTags()
    STATE.NUM_SLOTS = 4
    STATE.SCROLL_INDEX = 1
    local valueMeter = SKIN:GetMeter('Slot1Value')
    local maxValueStringLength = math.round(valueMeter:GetW() / valueMeter:GetOption('FontSize'))
    do
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, STATE.NUM_SLOTS do
        _accum_0[_len_0] = Slot(i, maxValueStringLength)
        _len_0 = _len_0 + 1
      end
      COMPONENTS.SLOTS = _accum_0
    end
    local scrollbar = SKIN:GetMeter('Scrollbar')
    STATE.SCROLLBAR.START = scrollbar:GetY()
    STATE.SCROLLBAR.MAX_HEIGHT = scrollbar:GetH()
    STATE.SUPPORTED_BANNER_EXTENSIONS = STATE.ALL_PLATFORMS[1]:getBannerExtensions()
    SKIN:Bang(('[!SetOption "SaveButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_save', 'Save')))
    SKIN:Bang(('[!SetOption "CancelButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_cancel', 'Cancel')))
    SKIN:Bang('[!CommandMeasure "Script" "HandshakeGame()" "#ROOTCONFIG#"]')
    return COMPONENTS.STATUS:hide()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Update = function() end
local updateTitle
updateTitle = function(game, maxStringLength)
  local title = utility.replaceUnsupportedChars(game:getTitle())
  SKIN:Bang(('[!SetOption "PageTitle" "Text" "%s"]'):format(title))
  if title:len() > maxStringLength then
    SKIN:Bang(('[!SetOption "PageTitle" "ToolTipText" "%s"]'):format(title))
    return SKIN:Bang('[!SetOption "PageTitle" "ToolTipHidden" "0"]')
  else
    return SKIN:Bang('[!SetOption "PageTitle" "ToolTipHidden" "1"]')
  end
end
local updateBanner
updateBanner = function(game)
  local path = game:getBanner()
  if not (path) then
    SKIN:Bang('[!SetOption "Banner" "ImageName" "#@#game\\gfx\\blank.png"]')
    SKIN:Bang(('[!SetOption "BannerMissing" "Text" "%s"]'):format(LOCALIZATION:get('game_no_banner', 'No banner')))
    local expectedBanner = game:getExpectedBanner()
    if expectedBanner then
      local extensions = table.concat(STATE.SUPPORTED_BANNER_EXTENSIONS, '|'):gsub('%.', '')
      local tooltip
      local _exp_0 = game:getPlatformID()
      if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
        local platformOverride = game:getPlatformOverride()
        if platformOverride ~= nil then
          tooltip = ('\\@Resources\\Shortcuts\\%s\\%s.%s'):format(platformOverride, expectedBanner, extensions)
        else
          tooltip = ('\\@Resources\\Shortcuts\\%s.%s'):format(expectedBanner, extensions)
        end
      elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 then
        if game:getPlatformOverride() then
          tooltip = ('\\@Resources\\cache\\steam_shortcuts\\%s.%s'):format(expectedBanner, extensions)
        else
          tooltip = ('\\@Resources\\cache\\steam\\%s.%s'):format(expectedBanner, extensions)
        end
      elseif ENUMS.PLATFORM_IDS.BATTLENET == _exp_0 then
        tooltip = ('\\@Resources\\cache\\battlenet\\%s.%s'):format(expectedBanner, extensions)
      elseif ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
        tooltip = ('\\@Resources\\cache\\gog_galaxy\\%s.%s'):format(expectedBanner, extensions)
      elseif ENUMS.PLATFORM_IDS.CUSTOM == _exp_0 then
        tooltip = ('\\@Resources\\cache\\custom\\%s.%s'):format(expectedBanner, extensions)
      end
      SKIN:Bang(('[!SetOption "BannerMissing" "ToolTipText" "%s"]'):format(tooltip))
      SKIN:Bang('[!SetOption "BannerMissing" "ToolTipHidden" "0"]')
      return 
    end
  end
  SKIN:Bang(('[!SetOption "Banner" "ImageName" "#@#%s"]'):format(path))
  SKIN:Bang('[!SetOption "BannerMissing" "Text" ""]')
  return SKIN:Bang('[!SetOption "BannerMissing" "ToolTipHidden" "1"]')
end
local updateScrollbar
updateScrollbar = function()
  STATE.MAX_SCROLL_INDEX = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
  local div = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
  if div < 1 then
    div = 1
  end
  STATE.SCROLLBAR.HEIGHT = math.round(STATE.SCROLLBAR.MAX_HEIGHT / div)
  div = (#STATE.PROPERTIES - STATE.NUM_SLOTS)
  if div < 1 then
    div = 1
  end
  STATE.SCROLLBAR.STEP = (STATE.SCROLLBAR.MAX_HEIGHT - STATE.SCROLLBAR.HEIGHT) / div
  SKIN:Bang(('[!SetOption "Scrollbar" "H" "%d"]'):format(STATE.SCROLLBAR.HEIGHT))
  local y = STATE.SCROLLBAR.START + (STATE.SCROLL_INDEX - 1) * STATE.SCROLLBAR.STEP
  return SKIN:Bang(('[!SetOption "Scrollbar" "Y" "%d"]'):format(math.round(y)))
end
local updateSlots
updateSlots = function()
  for i, slot in ipairs(COMPONENTS.SLOTS) do
    slot:populate(STATE.PROPERTIES[i + STATE.SCROLL_INDEX - 1])
    if i == STATE.HIGHLIGHTED_SLOT_INDEX then
      if slot:hasAction() then
        MouseOver(i)
      else
        MouseLeave(i)
      end
    end
  end
end
local sortPropertiesByTitle
sortPropertiesByTitle = function(a, b)
  return a.title:lower() < b.title:lower()
end
local createTagProperty
createTagProperty = function(tag, state)
  local f
  f = function()
    local _exp_0 = STATE.GAME_TAGS[tag]
    if ENUMS.TAG_STATES.DISABLED == _exp_0 then
      return LOCALIZATION:get('button_label_disabled', 'Disabled')
    elseif ENUMS.TAG_STATES.ENABLED == _exp_0 then
      return LOCALIZATION:get('button_label_enabled', 'Enabled')
    elseif ENUMS.TAG_STATES.ENABLED_PLATFORM == _exp_0 then
      return LOCALIZATION:get('button_label_enabled', 'Enabled') .. '*'
    end
  end
  if state == ENUMS.TAG_STATES.ENABLED_PLATFORM then
    return Property({
      title = tag,
      value = f(),
      update = f
    })
  else
    return Property({
      title = tag,
      value = f(),
      action = function(self, index)
        local old = STATE.GAME_TAGS[tag]
        local _exp_0 = STATE.GAME_TAGS[tag]
        if ENUMS.TAG_STATES.DISABLED == _exp_0 then
          STATE.GAME_TAGS[tag] = ENUMS.TAG_STATES.ENABLED
        elseif ENUMS.TAG_STATES.ENABLED == _exp_0 then
          STATE.GAME_TAGS[tag] = ENUMS.TAG_STATES.DISABLED
        else
          STATE.GAME_TAGS[tag] = STATE.GAME_TAGS[tag]
        end
      end,
      update = f
    })
  end
end
local createTagProperties
createTagProperties = function()
  local properties = { }
  for tag, state in pairs(STATE.GAME_TAGS) do
    table.insert(properties, createTagProperty(tag, state))
  end
  table.sort(properties, sortPropertiesByTitle)
  table.insert(properties, 1, Property({
    title = LOCALIZATION:get('game_tag_create', 'Create a new tag'),
    value = '',
    action = function(self, index)
      return StartCreatingTag(index)
    end
  }))
  return properties
end
local createPlatformProperty
createPlatformProperty = function(game, platform)
  local get
  get = function()
    local platformOverride = game:getPlatformOverride()
    if platformOverride ~= nil then
      return platformOverride .. '*'
    else
      return platform:getName()
    end
  end
  local action
  local _exp_0 = platform:getPlatformID()
  if ENUMS.PLATFORM_IDS.CUSTOM == _exp_0 then
    action = function(self, index)
      return StartEditingPlatformOverride(index)
    end
  else
    action = nil
  end
  return Property({
    title = LOCALIZATION:get('game_platform', 'Platform'),
    value = get(),
    update = get,
    action = action
  })
end
local createHoursPlayedProperty
createHoursPlayedProperty = function(game)
  local f
  f = function(self)
    return ('%.0f'):format(game:getHoursPlayed())
  end
  return Property({
    title = LOCALIZATION:get('button_label_hours_played', 'Hours played'),
    value = f(),
    action = function(self, index)
      return StartEditingHoursPlayed(index)
    end,
    update = f
  })
end
local createLastPlayedProperty
createLastPlayedProperty = function(game)
  local f
  f = function(self)
    local lastPlayed = game:getLastPlayed()
    if lastPlayed > 315532800 then
      local date = os.date('*t', lastPlayed)
      return ('%04.f-%02.f-%02.f %02.f:%02.f:%02.f'):format(date.year, date.month, date.day, date.hour, date.min, date.sec)
    end
    return LOCALIZATION:get('game_last_played_never', 'Never')
  end
  return Property({
    title = LOCALIZATION:get('game_last_played', 'Last played'),
    value = f()
  })
end
local createInstalledProperty
createInstalledProperty = function(game)
  local f
  f = function(self)
    if game:isInstalled() then
      return LOCALIZATION:get('button_label_yes', 'Yes')
    end
    return LOCALIZATION:get('button_label_no', 'No')
  end
  local action
  if game:getPlatformID() ~= ENUMS.PLATFORM_IDS.CUSTOM then
    action = nil
  else
    action = function(self)
      return game:setInstalled(not game:isInstalled())
    end
  end
  return Property({
    title = LOCALIZATION:get('game_installed', 'Installed'),
    value = f(),
    update = f,
    action = action
  })
end
local createVisibleProperty
createVisibleProperty = function(game)
  local f
  f = function(self)
    if game:isVisible() then
      return LOCALIZATION:get('button_label_yes', 'Yes')
    end
    return LOCALIZATION:get('button_label_no', 'No')
  end
  return Property({
    title = LOCALIZATION:get('game_visible', 'Visible'),
    value = f(),
    action = function(self, index)
      return STATE.GAME:toggleVisibility()
    end,
    update = f
  })
end
local createPathProperty
createPathProperty = function(game)
  local action = nil
  if game:getPlatformID() == ENUMS.PLATFORM_IDS.CUSTOM then
    action = function(self, index)
      return StartEditingPath(index)
    end
  else
    local path = game:getPath():match('"(.-)"')
    if path ~= nil and io.fileExists(path, false) then
      local head, tail = io.splitPath(path)
      if head ~= nil then
        action = function(self, index)
          return SKIN:Bang(('["%s"]'):format(head))
        end
      end
    end
  end
  local get
  get = function(self)
    return ('""%s""'):format(game:getPath())
  end
  return Property({
    title = LOCALIZATION:get('game_path', 'Path'),
    value = get(),
    update = get,
    action = action
  })
end
local createProcessProperty
createProcessProperty = function(game)
  local f
  f = function(self)
    local processOverride = game:getProcessOverride()
    if processOverride ~= nil and processOverride ~= '' then
      return processOverride .. '*'
    end
    local process = game:getProcess(true)
    if process ~= nil and process ~= '' then
      return process
    end
    return LOCALIZATION:get('game_process_none', 'None')
  end
  return Property({
    title = LOCALIZATION:get('game_process', 'Process'),
    value = f(),
    action = function(self, index)
      return StartEditingProcessOverride(index)
    end,
    update = f
  })
end
local createNotesProperty
createNotesProperty = function(game)
  local f
  f = function(self)
    local notes = game:getNotes()
    if notes ~= nil and notes:len() > 0 then
      local lines = notes:splitIntoLines()
      local line = lines[1]
      if #lines > 1 then
        line = line .. '...'
      end
      return line
    end
    return LOCALIZATION:get('game_notes_none', 'None')
  end
  return Property({
    title = LOCALIZATION:get('game_notes', 'Notes'),
    value = f(),
    action = function(self, index)
      return StartEditingNotes()
    end,
    update = f
  })
end
local createTagsProperty
createTagsProperty = function(game)
  local sourcePlatform = ENUMS.TAG_SOURCES.PLATFORM
  local f
  f = function(self)
    local gameTags, n = game:getTags()
    if n > 0 then
      local tags
      do
        local _accum_0 = { }
        local _len_0 = 1
        for tag, source in pairs(gameTags) do
          _accum_0[_len_0] = {
            tag = tag,
            fromPlatform = source == sourcePlatform
          }
          _len_0 = _len_0 + 1
        end
        tags = _accum_0
      end
      table.sort(tags, function(a, b)
        return a.tag < b.tag
      end)
      local str = ''
      for _index_0 = 1, #tags do
        local entry = tags[_index_0]
        str = str .. (' | ' .. entry.tag)
        if entry.fromPlatform then
          str = str .. '*'
        end
      end
      if str ~= '' then
        return str:sub(4)
      end
    end
    return LOCALIZATION:get('game_tags_none', 'None')
  end
  local sourceSkin = ENUMS.TAG_SOURCES.SKIN
  local enabledSkin = ENUMS.TAG_STATES.ENABLED
  local enabledPlatform = ENUMS.TAG_STATES.ENABLED_PLATFORM
  return Property({
    title = LOCALIZATION:get('game_tags', 'Tags'),
    value = f(),
    action = function(self, index)
      local gameTags, n = game:getTags()
      do
        local _tbl_0 = { }
        for tag, state in pairs(STATE.ALL_TAGS) do
          _tbl_0[tag] = state
        end
        STATE.GAME_TAGS = _tbl_0
      end
      local currentGameTags = STATE.GAME_TAGS
      for tag, source in pairs(gameTags) do
        if source == sourceSkin then
          currentGameTags[tag] = enabledSkin
        else
          currentGameTags[tag] = enabledPlatform
        end
      end
      SKIN:Bang(('[!SetOption "SaveButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_accept', 'Accept')))
      STATE.TAG_PROPERTIES = createTagProperties()
      STATE.PROPERTIES = STATE.TAG_PROPERTIES
      STATE.PREVIOUS_SCROLL_INDEX = STATE.SCROLL_INDEX
      STATE.SCROLL_INDEX = 1
      updateScrollbar()
      return updateSlots()
    end,
    update = f
  })
end
local createIgnoresOtherBangsProperty
createIgnoresOtherBangsProperty = function(game)
  local f
  f = function(self)
    if game:getIgnoresOtherBangs() then
      return LOCALIZATION:get('button_label_yes', 'Yes')
    end
    return LOCALIZATION:get('button_label_no', 'No')
  end
  return Property({
    title = LOCALIZATION:get('game_ignores_other_bangs', 'Ignores other bangs'),
    value = f(),
    action = function(self, index)
      return STATE.GAME:toggleIgnoresOtherBangs()
    end,
    update = f
  })
end
local createStartingBangsProperty
createStartingBangsProperty = function(game)
  local f
  f = function(self)
    local bangs = game:getStartingBangs()
    if bangs and #bangs > 0 then
      bangs = table.concat(bangs, ' | ')
      if bangs ~= '' then
        return (bangs:gsub('\"', '\'\''))
      end
    end
    return LOCALIZATION:get('button_label_bangs_none', 'None')
  end
  return Property({
    title = LOCALIZATION:get('button_label_starting_bangs', 'Starting bangs'),
    value = f(),
    action = function(self, index)
      return StartEditingStartingBangs()
    end,
    update = f
  })
end
local createStoppingBangsProperty
createStoppingBangsProperty = function(game)
  local f
  f = function(self)
    local bangs = game:getStoppingBangs()
    if bangs and #bangs > 0 then
      bangs = table.concat(bangs, ' | ')
      if bangs ~= '' then
        return (bangs:gsub('\"', '\'\''))
      end
    end
    return LOCALIZATION:get('button_label_bangs_none', 'None')
  end
  return Property({
    title = LOCALIZATION:get('button_label_stopping_bangs', 'Stopping bangs'),
    value = f(),
    action = function(self, index)
      return StartEditingStoppingBangs()
    end,
    update = f
  })
end
local createBannerReacquisitionProperty
createBannerReacquisitionProperty = function(game, platform)
  local title = LOCALIZATION:get('button_label_update_banner', 'Update banner')
  local value = LOCALIZATION:get('button_label_detect_download', 'Detect/download')
  local action
  action = function(self)
    local path = game:getBanner()
    local exists
    if path == nil then
      exists = false
    else
      exists = io.fileExists(path)
    end
    if not (path ~= nil and exists) then
      if path == nil then
        local expectedBanner = game:getExpectedBanner()
        if expectedBanner == nil then
          return 
        end
        local _exp_0 = game:getPlatformID()
        if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
          local platformOverride = game:getPlatformOverride()
          if platformOverride ~= nil then
            path = ('Shortcuts\\%s\\%s'):format(platformOverride, expectedBanner)
          else
            path = ('Shortcuts\\%s'):format(expectedBanner)
          end
        elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 then
          if game:getPlatformOverride() then
            path = ('cache\\steam_shortcuts\\%s'):format(expectedBanner)
          end
        end
        if path == nil then
          path = io.joinPaths(platform:getCachePath(), expectedBanner)
        end
      else
        path = path:reverse():match('^[^%.]+%.(.-)'):reverse()
      end
      local _list_0 = STATE.SUPPORTED_BANNER_EXTENSIONS
      for _index_0 = 1, #_list_0 do
        local extension = _list_0[_index_0]
        local newPath = ('%s%s'):format(path, extension)
        if io.fileExists(newPath) then
          game:setBanner(newPath)
          updateBanner(game)
          return 
        end
      end
    end
    local _exp_0 = game:getPlatformID()
    if ENUMS.PLATFORM_IDS.STEAM == _exp_0 or ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
      if game:getPlatformOverride() == nil then
        SKIN:Bang(('[!CommandMeasure "Script" "ReacquireBanner(%d)" "#ROOTCONFIG#"]'):format(game:getGameID()))
        return 
      end
    end
    if not (exists) then
      game:setBanner(nil)
      return updateBanner(game)
    end
  end
  return Property({
    title = title,
    value = value,
    action = action
  })
end
local createOpenStorePageProperty
createOpenStorePageProperty = function(game)
  local value = LOCALIZATION:get('button_label_platform_not_supported', 'Platform not supported')
  local action = nil
  local _exp_0 = game:getPlatformID()
  if ENUMS.PLATFORM_IDS.STEAM == _exp_0 or ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
    if game:getPlatformOverride() == nil then
      value = LOCALIZATION:get('button_label_platform_supported', 'Platform supported')
      action = function()
        SKIN:Bang(('[!CommandMeasure "Script" "OpenStorePage(%d)" "#ROOTCONFIG#"]'):format(game:getGameID()))
        return SKIN:Bang('[!DeactivateConfig]')
      end
    end
  end
  return Property({
    title = LOCALIZATION:get('button_label_open_store_page', 'Open store page'),
    value = value,
    action = action,
    update = nil
  })
end
local createProperties
createProperties = function(game, platform)
  return {
    createPlatformProperty(game, platform),
    createHoursPlayedProperty(game),
    createLastPlayedProperty(game),
    createInstalledProperty(game),
    createVisibleProperty(game),
    createPathProperty(game),
    createProcessProperty(game),
    createNotesProperty(game),
    createTagsProperty(game),
    createIgnoresOtherBangsProperty(game),
    createStartingBangsProperty(game),
    createStoppingBangsProperty(game),
    createBannerReacquisitionProperty(game, platform),
    createOpenStorePageProperty(game)
  }
end
local centerConfig
centerConfig = function()
  if STATE.CENTERED == true then
    return 
  end
  STATE.CENTERED = true
  if not COMPONENTS.SETTINGS:getCenterOnMonitor() then
    return 
  end
  local meter = SKIN:GetMeter('WindowShadow')
  local skinWidth = meter:GetW()
  local skinHeight = meter:GetH()
  local mainConfig = utility.getConfig(SKIN:GetVariable('ROOTCONFIG'))
  local monitorIndex = nil
  if mainConfig ~= nil then
    monitorIndex = utility.getConfigMonitor(mainConfig) or 1
  else
    monitorIndex = 1
  end
  local x, y = utility.centerOnMonitor(skinWidth, skinHeight, monitorIndex)
  return SKIN:Bang(('[!Move "%d" "%d"]'):format(x, y))
end
local getPlatform
getPlatform = function(game)
  local platformID = game:getPlatformID()
  local _list_0 = STATE.ALL_PLATFORMS
  for _index_0 = 1, #_list_0 do
    local p = _list_0[_index_0]
    if p:getPlatformID() == platformID then
      return p
    end
  end
  return nil
end
local getGame
getGame = function(gameID)
  local game = STATE.ALL_GAMES[gameID]
  if game == nil or game:getGameID() ~= gameID then
    local _list_0 = STATE.ALL_GAMES
    for _index_0 = 1, #_list_0 do
      local game = _list_0[_index_0]
      if game:getGameID() == gameID then
        return game
      end
    end
  end
  return game
end
Handshake = function(gameID)
  local success, err = pcall(function()
    log('Accepting Game handshake', gameID)
    local game = getGame(gameID)
    assert(game ~= nil, ('Could not find a game with the gameID: %d'):format(gameID))
    STATE.GAME = game
    local valueMeter = SKIN:GetMeter('PageTitle')
    local maxStringLength = math.round(valueMeter:GetW() / valueMeter:GetOption('FontSize'))
    updateTitle(game, maxStringLength)
    updateBanner(game)
    local platform = getPlatform(game)
    assert(platform ~= nil, 'Could not find the game\'s platform.')
    STATE.DEFAULT_PROPERTIES = createProperties(game, platform)
    STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
    updateScrollbar()
    updateSlots()
    centerConfig()
    return SKIN:Bang('[!ZPos 1][!Show]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Scroll = function(direction)
  if not (COMPONENTS.SLOTS ~= nil) then
    return 
  end
  local index = STATE.SCROLL_INDEX + direction
  if index < 1 then
    return 
  elseif index > STATE.MAX_SCROLL_INDEX then
    return 
  end
  STATE.SCROLL_INDEX = index
  updateScrollbar()
  return updateSlots()
end
MouseOver = function(index)
  if not (COMPONENTS.SLOTS ~= nil) then
    return 
  end
  STATE.HIGHLIGHTED_SLOT_INDEX = index
  if not (COMPONENTS.SLOTS[index] ~= nil and COMPONENTS.SLOTS[index]:hasAction()) then
    return 
  end
  return SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]'):format(index))
end
MouseLeave = function(index)
  if not (COMPONENTS.SLOTS ~= nil) then
    return 
  end
  if index == 0 then
    STATE.HIGHLIGHTED_SLOT_INDEX = 0
    for i = index, STATE.NUM_SLOTS do
      SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]'):format(i))
    end
  else
    return SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]'):format(index))
  end
end
MouseLeftPress = function(index)
  local slots = COMPONENTS.SLOTS
  if not (slots ~= nil and slots[index] ~= nil and slots[index]:hasAction()) then
    return 
  end
  return SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonPressedColor#"]'):format(index))
end
ButtonAction = function(index)
  local slots = COMPONENTS.SLOTS
  if not (slots ~= nil and slots[index] ~= nil and slots[index]:hasAction()) then
    return 
  end
  SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]'):format(index))
  slots[index]:action()
  return updateSlots()
end
local showDefaultProperties
showDefaultProperties = function()
  local bangs = ('[!SetOption "SaveButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_save', 'Save'))
  bangs = bangs .. ('[!SetOption "CancelButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_cancel', 'Cancel'))
  SKIN:Bang(bangs)
  STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
  STATE.SCROLL_INDEX = STATE.PREVIOUS_SCROLL_INDEX
  STATE.PREVIOUS_SCROLL_INDEX = 1
  updateScrollbar()
  return updateSlots()
end
Save = function()
  local success, err = pcall(function()
    if STATE.ACTIVE_INPUT == true then
      return 
    end
    local _exp_0 = STATE.PROPERTIES
    if STATE.DEFAULT_PROPERTIES == _exp_0 then
      io.writeJSON(STATE.PATHS.GAMES, {
        version = STATE.GAMES_VERSION,
        tagsDictionary = STATE.TAGS_DICTIONARY,
        games = STATE.ALL_GAMES,
        updated = STATE.GAMES_UPDATED_TIMESTAMP
      })
      local gameID = STATE.GAME:getGameID()
      local bangs = ('[!CommandMeasure "Script" "UpdateGame(%d)" "#ROOTCONFIG#"]'):format(gameID)
      bangs = bangs .. '[!DeactivateConfig]'
      return SKIN:Bang(bangs)
    elseif STATE.TAG_PROPERTIES == _exp_0 then
      local tags = { }
      local sourceSkin = ENUMS.TAG_SOURCES.SKIN
      local sourcePlatform = ENUMS.TAG_SOURCES.PLATFORM
      local enabledSkin = ENUMS.TAG_STATES.ENABLED
      local enabledPlatform = ENUMS.TAG_STATES.ENABLED_PLATFORM
      for tag, state in pairs(STATE.GAME_TAGS) do
        if state == enabledSkin then
          tags[tag] = sourceSkin
        elseif state == enabledPlatform then
          tags[tag] = sourcePlatform
        end
      end
      STATE.GAME:setTags(tags)
      return showDefaultProperties()
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Cancel = function()
  local success, err = pcall(function()
    if STATE.ACTIVE_INPUT == true then
      return 
    end
    local _exp_0 = STATE.PROPERTIES
    if STATE.DEFAULT_PROPERTIES == _exp_0 then
      return SKIN:Bang('[!DeactivateConfig]')
    elseif STATE.TAG_PROPERTIES == _exp_0 then
      return showDefaultProperties()
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OpenBanner = function()
  local success, err = pcall(function()
    local path = SKIN:GetMeter('Banner'):GetOption('ImageName')
    if path ~= nil and path ~= '' and path:match('@Resources\\game\\gfx\\') == nil then
      return SKIN:Bang(('"%s"'):format(path))
    else
      local game = STATE.GAME
      local _exp_0 = game:getPlatformID()
      if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
        local platformOverride = game:getPlatformOverride()
        if platformOverride ~= nil then
          path = ('Shortcuts\\%s\\'):format(platformOverride)
        else
          path = 'Shortcuts\\'
        end
      elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 then
        if game:getPlatformOverride() then
          path = 'cache\\steam_shortcuts\\'
        else
          path = 'cache\\steam\\'
        end
      elseif ENUMS.PLATFORM_IDS.BATTLENET == _exp_0 then
        path = 'cache\\battlenet\\'
      elseif ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
        path = 'cache\\gog_galaxy\\'
      elseif ENUMS.PLATFORM_IDS.CUSTOM == _exp_0 then
        path = 'cache\\custom\\'
      end
      return SKIN:Bang(('"#@#%s"'):format(path))
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnDismissedInput = function()
  local success, err = pcall(function()
    STATE.ACTIVE_INPUT = false
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local startEditing
startEditing = function(slotIndex, batchIndex, defaultValue)
  local meter = SKIN:GetMeter(('Slot%dValue'):format(slotIndex))
  SKIN:Bang(('[!SetOption "Input" "X" "%d"]'):format(meter:GetX() - 1))
  SKIN:Bang(('[!SetOption "Input" "Y" "%d"]'):format(meter:GetY() - 1))
  SKIN:Bang(('[!SetOption "Input" "W" "%d"]'):format(meter:GetW()))
  SKIN:Bang(('[!SetOption "Input" "H" "%d"]'):format(20))
  if defaultValue == nil then
    defaultValue = ''
  end
  SKIN:Bang(('[!SetOption "Input" "DefaultValue" "%s"]'):format(defaultValue))
  SKIN:Bang(('[!CommandMeasure "Input" "ExecuteBatch %d"]'):format(batchIndex))
  STATE.ACTIVE_INPUT = true
end
StartEditingPlatformOverride = function(index)
  local success, err = pcall(function()
    return startEditing(index, 4, STATE.GAME:getPlatformOverride())
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedPlatformOverride = function(platform)
  local success, err = pcall(function()
    STATE.GAME:setPlatformOverride(platform:sub(1, -2))
    updateSlots()
    return OnDismissedInput()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingPath = function(index)
  local success, err = pcall(function()
    return startEditing(index, 5, STATE.GAME:getPath())
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedPath = function(path)
  local success, err = pcall(function()
    STATE.GAME:setPath(path:sub(1, -2))
    updateSlots()
    return OnDismissedInput()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingProcessOverride = function(index)
  local success, err = pcall(function()
    return startEditing(index, 1, STATE.GAME:getProcessOverride())
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedProcessOverride = function(process)
  local success, err = pcall(function()
    STATE.GAME:setProcessOverride(process:sub(1, -2))
    updateSlots()
    return OnDismissedInput()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingHoursPlayed = function(index)
  local success, err = pcall(function()
    return startEditing(index, 3, STATE.GAME:getHoursPlayed())
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedHoursPlayed = function(hoursPlayed)
  local success, err = pcall(function()
    STATE.GAME:setHoursPlayed(tonumber((hoursPlayed:sub(1, -2):gsub(',', '.'))))
    updateSlots()
    return OnDismissedInput()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartCreatingTag = function(index)
  local success, err = pcall(function()
    return startEditing(index, 2)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnCreatedTag = function(tag)
  local success, err = pcall(function()
    OnDismissedInput()
    tag = tag:sub(1, -2)
    if STATE.ALL_TAGS[tag] ~= nil then
      return 
    end
    STATE.ALL_TAGS[tag] = ENUMS.TAG_STATES.DISABLED
    STATE.GAME_TAGS[tag] = ENUMS.TAG_STATES.ENABLED
    local createProperty = table.remove(STATE.TAG_PROPERTIES, 1)
    table.insert(STATE.TAG_PROPERTIES, createTagProperty(tag, STATE.GAME_TAGS[tag]))
    table.sort(STATE.TAG_PROPERTIES, sortPropertiesByTitle)
    table.insert(STATE.TAG_PROPERTIES, 1, createProperty)
    updateScrollbar()
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingStartingBangs = function()
  local success, err = pcall(function()
    SKIN:Bang('[!ZPos 0]')
    local bangs = STATE.GAME:getStartingBangs()
    io.writeFile(STATE.PATHS.BANGS, table.concat(bangs, '\n'))
    return utility.runCommand(('""..\\@Resources\\%s""'):format(STATE.PATHS.BANGS), '', 'OnEditedStartingBangs')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedStartingBangs = function()
  local success, err = pcall(function()
    local bangs = io.readFile(STATE.PATHS.BANGS)
    STATE.GAME:setStartingBangs(bangs:splitIntoLines())
    updateSlots()
    return SKIN:Bang('[!ZPos 1]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingStoppingBangs = function()
  local success, err = pcall(function()
    SKIN:Bang('[!ZPos 0]')
    local bangs = STATE.GAME:getStoppingBangs()
    io.writeFile(STATE.PATHS.BANGS, table.concat(bangs, '\n'))
    return utility.runCommand(('""..\\@Resources\\%s""'):format(STATE.PATHS.BANGS), '', 'OnEditedStoppingBangs')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedStoppingBangs = function()
  local success, err = pcall(function()
    local bangs = io.readFile(STATE.PATHS.BANGS)
    STATE.GAME:setStoppingBangs(bangs:splitIntoLines())
    updateSlots()
    return SKIN:Bang('[!ZPos 1]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
ToggleIgnoresOtherBangs = function()
  local success, err = pcall(function()
    STATE.GAME:toggleIgnoresOtherBangs()
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingNotes = function()
  local success, err = pcall(function()
    SKIN:Bang('[!ZPos 0]')
    local notes = STATE.GAME:getNotes()
    if notes == nil then
      notes = ''
    end
    io.writeFile(STATE.PATHS.NOTES, notes)
    return utility.runCommand(('""..\\@Resources\\%s""'):format(STATE.PATHS.NOTES), '', 'OnEditedNotes')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedNotes = function()
  local success, err = pcall(function()
    local notes = io.readFile(STATE.PATHS.NOTES)
    STATE.GAME:setNotes(notes)
    updateSlots()
    return SKIN:Bang('[!ZPos 1]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnReacquiredBanner = function()
  local success, err = pcall(function()
    return updateBanner(STATE.GAME)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
