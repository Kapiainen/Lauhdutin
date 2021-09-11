local Platform = require('main.platforms.platform')
local Custom
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    validate = function(self) end,
    detectBanners = function(self, oldGames)
      for _index_0 = 1, #oldGames do
        local game = oldGames[_index_0]
        if game:getPlatformID() == ENUMS.PLATFORM_IDS.CUSTOM then
          local path = game:getBanner()
          if path ~= nil and not io.fileExists(path) then
            game:setBanner(nil)
          elseif path == nil then
            game:setBanner(self:getBannerPath(game:getExpectedBanner()))
          end
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, settings)
      _class_0.__parent.__init(self, settings)
      self.platformID = ENUMS.PLATFORM_IDS.CUSTOM
      self.name = LOCALIZATION:get('platform_name_custom', 'Custom')
      self.cachePath = 'cache\\custom\\'
      self.enabled = true
    end,
    __base = _base_0,
    __name = "Custom",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Custom = _class_0
end
return Custom
