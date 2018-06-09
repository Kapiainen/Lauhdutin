local Game
do
  local _class_0
  local _base_0 = {
    merge = function(self, other, newer)
      if newer == nil then
        newer = false
      end
      assert(other.__class == Game, 'main.game.Game.merge')
      log('Merging: ' .. other.title)
      if newer == true then
        self.banner = other.banner
        self.bannerURL = other.bannerURL
        self.expectedBanner = other.expectedBanner
      end
    end,
    getBasePrice = function(self)
      return self.basePrice
    end,
    getFinalPrice = function(self)
      return self.finalPrice
    end,
    getDiscountPercentage = function(self)
      return self.discountPercentage
    end,
    getFree = function(self)
      return self.isFree
    end,
    getPrerelease = function(self)
      return self.isPrerelease
    end,
    getTitle = function(self)
      return self.title
    end,
    getPlatformID = function(self)
      return self.platformID
    end,
    getGameID = function(self)
      return self.gameID
    end,
    setGameID = function(self, value)
      self.gameID = value
    end,
    getPlatformOverride = function(self)
      return nil
    end,
    setPlatformOverride = function(self) end,
    getPath = function(self)
      return nil
    end,
    setPath = function(self) end,
    getProcess = function(self)
      return ''
    end,
    getProcessOverride = function(self)
      return self.processOverride
    end,
    setProcessOverride = function(self) end,
    getBanner = function(self)
      return self.banner
    end,
    setBanner = function(self, path)
      if path == nil then
        self.banner = nil
      elseif type(path) == 'string' then
        path = path:trim()
        if path == '' then
          self.banner = nil
        else
          self.banner = path
        end
      end
    end,
    getExpectedBanner = function(self)
      return self.expectedBanner
    end,
    setExpectedBanner = function(self, str)
      if str == nil then
        return self.expectedBanner == nil
      elseif type(str) == 'string' then
        str = str:trim()
        if str == '' then
          self.expectedBanner = nil
        else
          self.expectedBanner = str
        end
      end
    end,
    getBannerURL = function(self)
      return self.bannerURL
    end,
    setBannerURL = function(self, url)
      if url == nil then
        self.bannerURL = nil
      elseif type(url) == 'string' then
        url = url:trim()
        if url == '' then
          self.bannerURL = nil
        else
          self.bannerURL = url
        end
      end
    end,
    isVisible = function(self)
      return true
    end,
    setVisible = function(self) end,
    toggleVisibility = function(self) end,
    isInstalled = function(self)
      return true
    end,
    setInstalled = function(self) end,
    getLastPlayed = function(self)
      return 0
    end,
    setLastPlayed = function(self) end,
    getHoursPlayed = function(self)
      return 0
    end,
    setHoursPlayed = function(self) end,
    incrementHoursPlayed = function(self) end,
    getTags = function(self)
      return { }
    end,
    setTags = function(self) end,
    getPlatformTags = function(self)
      return { }
    end,
    hasTag = function(self)
      return false
    end,
    getStartingBangs = function(self)
      return { }
    end,
    setStartingBangs = function(self) end,
    getStoppingBangs = function(self)
      return { }
    end,
    setStoppingBangs = function(self) end,
    getIgnoresOtherBangs = function(self)
      return false
    end,
    toggleIgnoresOtherBangs = function(self) end,
    getNotes = function(self)
      return nil
    end,
    setNotes = function(self) end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, args)
      assert(type(args.title) == 'string' and args.title:trim() ~= '', 'wishlist.game.Game')
      self.title = utility.adjustTitle(args.title)
      assert(type(args.url) == 'string', 'wishlist.game.Game')
      self.url = args.url
      self.clientCommand = args.clientCommand
      assert(type(args.platformID) == 'number' and args.platformID % 1 == 0, 'wishlist.game.Game')
      self.platformID = args.platformID
      assert(self.platformID > 0 and self.platformID < ENUMS.PLATFORM_IDS.MAX, 'wishlist.game.Game')
      self.platformOverride = args.platformOverride
      if args.banner ~= nil and (io.fileExists(args.banner) or args.bannerURL ~= nil) then
        self.banner = args.banner
      end
      self.bannerURL = args.bannerURL
      assert(self.bannerURL == nil or (self.bannerURL ~= nil and self.banner ~= nil), 'wishlist.game.Game')
      self.expectedBanner = args.expectedBanner
      self.gameID = args.gameID
      self.isPrerelease = args.isPrerelease or false
      self.isFree = args.isFree or false
      assert(type(args.basePrice) == 'number', 'wishlist.game.Game')
      assert(type(args.finalPrice) == 'number', 'wishlist.game.Game')
      assert(type(args.discountPercentage) == 'number', 'wishlist.game.Game')
      self.basePrice = args.basePrice or 0
      self.finalPrice = args.finalPrice or 0
      self.discountPercentage = args.discountPercentage or 0
    end,
    __base = _base_0,
    __name = "Game"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Game = _class_0
end
return Game
