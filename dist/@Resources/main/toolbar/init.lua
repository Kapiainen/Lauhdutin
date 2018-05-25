local Toolbar
do
  local _class_0
  local _base_0 = {
    hide = function(self)
      return SKIN:Bang('[!HideMeterGroup "Toolbar"]')
    end,
    show = function(self)
      return SKIN:Bang('[!ShowMeterGroup "Toolbar"]')
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, settings)
      assert(type(settings) == 'table', 'main.toolbar.init.Toolbar')
      if not (settings:getLayoutToolbarAtTop()) then
        SKIN:Bang('[!SetOption "ToolbarBackground" "Y" "(#SkinHeight# - #ToolbarHeight#)]')
        SKIN:Bang('[!SetOption "ToolbarEnabler" "Y" "(#SkinHeight# - 1)]')
        return SKIN:Bang('[!UpdateMeterGroup "Toolbar"]')
      end
    end,
    __base = _base_0,
    __name = "Toolbar"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Toolbar = _class_0
end
return Toolbar
