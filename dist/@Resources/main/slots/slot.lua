local Slot
do
  local _class_0
  local _base_0 = {
    getGame = function(self)
      return self.game
    end,
    update = function(self, game)
      self.game = game
      if game == nil then
        log(('Updating slot %d with nothing'):format(self.index))
        SKIN:Bang(('[!SetOption "Slot%dText" "Text" ""]'):format(self.index))
        SKIN:Bang(('[!SetOption "Slot%dImage" "ImageName" ""]'):format(self.index))
        return 
      end
      log(('Updating slot %d with %s'):format(self.index, game:getTitle()))
      local banner = game:getBanner()
      if banner then
        SKIN:Bang(('[!SetOption "Slot%dText" "Text" ""]'):format(self.index))
        return SKIN:Bang(('[!SetOption "Slot%dImage" "ImageName" "#@#%s"]'):format(self.index, banner))
      else
        SKIN:Bang(('[!SetOption "Slot%dText" "Text" "%s"]'):format(self.index, game:getTitle()))
        return SKIN:Bang(('[!SetOption "Slot%dImage" "ImageName" ""]'):format(self.index))
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, index)
      assert(type(index) == 'number' and index % 1 == 0, 'main.slots.slot.Slot')
      self.index = index
      self.game = nil
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
return Slot
