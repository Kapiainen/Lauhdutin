local Slot = require('main.slots.slot')
local OverlaySlot = require('main.slots.overlay_slot')
local Slots
do
  local _class_0
  local _base_0 = {
    update = function(self)
      log('Updating slots')
      return SKIN:Bang('[!UpdateMeterGroup "Slots"]')
    end,
    populate = function(self, games, startIndex)
      if startIndex == nil then
        startIndex = 1
      end
      log('Populating slots')
      for i = 1, #self.slots do
        self.slots[i]:update(games[i + startIndex - 1])
      end
      self:hover(self.hoveringSlot)
      return #games > 0
    end,
    hover = function(self, index)
      if index == nil then
        index = self.hoveringSlot
      end
      if index < 1 then
        return false
      end
      self.hoveringSlot = index
      if not (self.focused) then
        return false
      end
      self.overlaySlot:show(index, self.slots[index]:getGame())
      local animationType = COMPONENTS.SETTINGS:getSlotsHoverAnimation()
      if animationType ~= ENUMS.SLOT_HOVER_ANIMATIONS.NONE then
        COMPONENTS.ANIMATIONS:resetSlots()
        local game = self:getGame(index)
        if game ~= nil then
          local banner = game:getBanner()
          if banner ~= nil then
            COMPONENTS.ANIMATIONS:pushSlotHover(index, animationType, banner)
            return true
          end
        end
        COMPONENTS.ANIMATIONS:resetSlots()
        COMPONENTS.ANIMATIONS:cancelAnimations()
      end
      return true
    end,
    getHoverIndex = function(self)
      return self.hoveringSlot
    end,
    leave = function(self, index)
      self.overlaySlot:hide()
      if not (self.focused) then
        return 
      end
      self.hoveringSlot = 0
    end,
    focus = function(self)
      self.focused = true
    end,
    unfocus = function(self)
      self.focused = false
    end,
    leftClick = function(self, index)
      COMPONENTS.ANIMATIONS:resetSlots()
      return self.slots[index]:getGame()
    end,
    middleClick = function(self, index)
      return self.slots[index]:getGame()
    end,
    getGame = function(self, index)
      return self.slots[index]:getGame()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, settings)
      assert(type(settings) == 'table', 'main.slots.init.Slots')
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, STATE.NUM_SLOTS do
          _accum_0[_len_0] = Slot(i)
          _len_0 = _len_0 + 1
        end
        self.slots = _accum_0
      end
      self.overlaySlot = OverlaySlot(settings)
      self.overlaySlot:hide()
      self.hoveringSlot = 0
      self.focused = true
    end,
    __base = _base_0,
    __name = "Slots"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Slots = _class_0
end
local launchGame
launchGame = function(game)
  game:setLastPlayed(os.time())
  COMPONENTS.LIBRARY:sort(COMPONENTS.SETTINGS:getSorting())
  COMPONENTS.LIBRARY:save()
  STATE.GAMES = COMPONENTS.LIBRARY:get()
  STATE.SCROLL_INDEX = 1
  COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
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
      elseif ENUMS.PLATFORM_IDS.CUSTOM == _exp_0 then
        platformBangs = COMPONENTS.SETTINGS:getCustomStartingBangs()
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
    SKIN:Bang('[!HideFade]')
  end
  if COMPONENTS.SETTINGS:getShowSession() then
    return SKIN:Bang(('[!ActivateConfig "%s"]'):format(('%s\\Session'):format(STATE.ROOT_CONFIG)))
  end
end
local installGame
installGame = function(game)
  game:setLastPlayed(os.time())
  game:setInstalled(true)
  COMPONENTS.LIBRARY:sort(COMPONENTS.SETTINGS:getSorting())
  COMPONENTS.LIBRARY:save()
  STATE.GAMES = COMPONENTS.LIBRARY:get()
  STATE.SCROLL_INDEX = 1
  COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
  return SKIN:Bang(('[%s]'):format(game:getPath()))
end
local hideGame
hideGame = function(game)
  if game:isVisible() == false then
    return 
  end
  game:setVisible(false)
  COMPONENTS.LIBRARY:save()
  local i = table.find(STATE.GAMES, game)
  if i ~= nil then
    table.remove(STATE.GAMES, i)
  end
  if #STATE.GAMES == 0 then
    COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.NONE)
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    OnContextToggleHideGames()
  end
  return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
end
local unhideGame
unhideGame = function(game)
  if game:isVisible() == true then
    return 
  end
  game:setVisible(true)
  COMPONENTS.LIBRARY:save()
  local i = table.find(STATE.GAMES, game)
  if i ~= nil then
    table.remove(STATE.GAMES, i)
  end
  if #STATE.GAMES == 0 then
    COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.NONE)
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    OnContextToggleUnhideGames()
  end
  return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
end
local removeGame
removeGame = function(game)
  COMPONENTS.LIBRARY:remove(game)
  local i = table.find(STATE.GAMES, game)
  if i ~= nil then
    table.remove(STATE.GAMES, i)
  end
  if #STATE.GAMES == 0 then
    COMPONENTS.LIBRARY:filter(ENUMS.FILTER_TYPES.NONE)
    STATE.GAMES = COMPONENTS.LIBRARY:get()
    STATE.SCROLL_INDEX = 1
    OnContextToggleRemoveGames()
  end
  return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_SLOTS)
end
OnSlotHover = function(index)
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
OnSlotsScroll = function(direction)
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
OnSlotLeftClick = function(index)
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
      local result = nil
      if game:isInstalled() == true then
        result = launchGame
      else
        local platformID = game:getPlatformID()
        if platformID == ENUMS.PLATFORM_IDS.STEAM and game:getPlatformOverride() == nil then
          result = installGame
        end
      end
      action = result
    elseif ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME == _exp_0 then
      action = hideGame
    elseif ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME == _exp_0 then
      action = unhideGame
    elseif ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME == _exp_0 then
      action = removeGame
    else
      action = assert(nil, 'main.init.OnLeftClickSlot')
    end
    if not (action) then
      return 
    end
    if not (COMPONENTS.ANIMATIONS:pushSlotClick(index, STATE.SLOT_CLICK_ANIMATION, action, game)) then
      return action(game)
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnSlotMiddleClick = function(index)
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
    local config = RAINMETER:GetConfig(configName)
    if STATE.GAME_BEING_MODIFIED == game and config:isActive() then
      STATE.GAME_BEING_MODIFIED = nil
      return SKIN:Bang(('[!DeactivateConfig "%s"]'):format(configName))
    end
    STATE.GAME_BEING_MODIFIED = game
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
OnSlotLeave = function(index)
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
return Slots
