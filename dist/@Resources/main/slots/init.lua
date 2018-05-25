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
return Slots
