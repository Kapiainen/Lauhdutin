local Slot = require('settings.slots.slot')
local Slots
do
  local _class_0
  local _base_0 = {
    updateScrollBar = function(self, numSettings)
      if numSettings > STATE.NUM_SLOTS then
        self.scrollBarHeight = math.round(self.scrollBarMaxHeight / (numSettings - STATE.NUM_SLOTS + 1))
        self.scrollBarStep = (self.scrollBarMaxHeight - self.scrollBarHeight) / (numSettings - STATE.NUM_SLOTS)
      else
        self.scrollBarHeight = self.scrollBarMaxHeight
        self.scrollBarStep = 0
      end
      return SKIN:Bang(('[!SetOption "ScrollBar" "H" "%d"]'):format(self.scrollBarHeight))
    end,
    update = function(self, settings)
      self.settings = settings
      self:updateScrollBar(#settings)
      self:scroll()
      return #settings - STATE.NUM_SLOTS + 1
    end,
    getNumSettings = function(self)
      return #self.settings
    end,
    getSetting = function(self, index)
      return self.settings[index + STATE.SCROLL_INDEX - 1]
    end,
    updateSlot = function(self, index)
      return self.slots[index]:update(self:getSetting(index))
    end,
    scroll = function(self)
      local yPos = self.scrollBarStart + (STATE.SCROLL_INDEX - 1) * self.scrollBarStep
      SKIN:Bang(('[!SetOption "ScrollBar" "Y" "%d"]'):format(yPos))
      for index = 1, STATE.NUM_SLOTS do
        self:updateSlot(index)
      end
    end,
    performAction = function(self, index)
      return self:getSetting(index):perform()
    end,
    toggleBoolean = function(self, index)
      self:getSetting(index):toggle()
      return self:updateSlot(index)
    end,
    startBrowsingFolderPath = function(self, index)
      return self:getSetting(index):startBrowsing()
    end,
    editFolderPath = function(self, index, path)
      self:getSetting(index):setValue(path)
      return self:updateSlot(index)
    end,
    cycleSpinner = function(self, index, direction)
      local setting = self:getSetting(index)
      setting:setIndex(setting:getIndex() + direction)
      return self:updateSlot(index)
    end,
    incrementInteger = function(self, index)
      self:getSetting(index):incrementValue()
      return self:updateSlot(index)
    end,
    decrementInteger = function(self, index)
      self:getSetting(index):decrementValue()
      return self:updateSlot(index)
    end,
    setInteger = function(self, index, value)
      self:getSetting(index):setValue(value)
      return self:updateSlot(index)
    end,
    cycleFolderPathSpinner = function(self, index, direction)
      local setting = self:getSetting(index)
      setting:setIndex(setting:getIndex() + direction)
      return self:updateSlot(index)
    end,
    startBrowsingFolderPathSpinner = function(self, index)
      return self:getSetting(index):startBrowsing()
    end,
    editFolderPathSpinner = function(self, index, path)
      local setting = self:getSetting(index)
      setting:setPath(setting.index, path)
      return self:updateSlot(index)
    end,
    editString = function(self, index, value)
      self:getSetting(index):setValue(value)
      return self:updateSlot(index)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, STATE.NUM_SLOTS do
          _accum_0[_len_0] = Slot(i)
          _len_0 = _len_0 + 1
        end
        self.slots = _accum_0
      end
      assert(#self.slots == STATE.NUM_SLOTS, 'settings.slots.init.Slots')
      self.settings = { }
      local scrollBar = SKIN:GetMeter('ScrollBar')
      assert(scrollBar ~= nil, 'settings.slots.init.Slots')
      if scrollBar then
        self.scrollBarStart = scrollBar:GetY()
      else
        self.scrollBarStart = 0
      end
      if scrollBar then
        self.scrollBarMaxHeight = scrollBar:GetH()
      else
        self.scrollBarMaxHeight = 0
      end
      self.scrollBarHeight = self.scrollBarMaxHeight
      self.scrollBarStep = 0
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
