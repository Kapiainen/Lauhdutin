local Pages
do
  local _class_0
  local _base_0 = {
    getCount = function(self)
      return #self.pages
    end,
    loadPage = function(self, index)
      assert(type(index) == 'number' and index % 1 == 0, 'settings.pages.init.Pages.loadPage')
      assert(index > 0 and index <= self:getCount(), 'settings.pages.init.Pages.loadPage')
      self.currentPage = self.pages[index]
      return self.currentPage:getTitle(), self.currentPage:getSettings()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.pages = {
        require('settings.pages.skin')(),
        require('settings.pages.shortcuts')(),
        require('settings.pages.steam')(),
        require('settings.pages.battlenet')(),
        require('settings.pages.gog_galaxy')(),
        require('settings.pages.custom')()
      }
      self.currentPage = nil
    end,
    __base = _base_0,
    __name = "Pages"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Pages = _class_0
end
return Pages
