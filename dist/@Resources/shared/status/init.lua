local Status
do
  local _class_0
  local _base_0 = {
    update = function(self)
      return SKIN:Bang('[!UpdateMeter "StatusMessage"]')
    end,
    show = function(self, message, exception)
      if exception == nil then
        exception = false
      end
      assert(type(message) == 'string', 'shared.status.init.Status')
      if not (self.visible) then
        SKIN:Bang('[!ShowMeter "StatusMessage"]')
      end
      self.visible = true
      if exception then
        self.exception = true
        local starts, ends = message:find('%[string ""%]:')
        if ends then
          message = 'Line ' .. message:sub(ends + 1)
        end
      end
      message = message:gsub('\"', '\'\'')
      if exception then
        SKIN:Bang(('[!Log "Error: %s" "Error"]'):format(message))
        message = ('Error:#CRLF#%s'):format(message)
      else
        log(message)
      end
      SKIN:Bang(('[!SetOption "StatusMessage" "Text" "%s"]'):format(message))
      return self:update()
    end,
    hide = function(self)
      if not (self.visible) then
        return 
      end
      if self.exception then
        return 
      end
      self.visible = false
      SKIN:Bang('[!HideMeter "StatusMessage"]')
      return self:update()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.visible = true
      self.exception = false
    end,
    __base = _base_0,
    __name = "Status"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Status = _class_0
end
return Status
