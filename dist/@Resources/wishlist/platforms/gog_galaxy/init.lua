local Platform = require('wishlist.platforms.platform')
local GOGGalaxy
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    validate = function(self)
      if self.clientPath ~= nil then
        self.clientPath = io.joinPaths(self.clientPath, 'GalaxyClient.exe')
        assert(io.fileExists(self.clientPath, false) == true, 'The path to the GOG Galaxy client is not valid.')
      end
      return assert(type(self.communityProfileName) == 'string' and #self.communityProfileName > 0, 'A GOG profile name has not been defined.')
    end,
    getWishlistURL = function(self)
      return ('https://www.gog.com/u/%s/wishlist'):format(self.communityProfileName), 'wishlist.txt', 'OnGOGWishlistDownloaded', 'OnGOGWishlistDownloadFailed'
    end,
    generateBannerURL = function(self, url)
      return ('https:%s_392.jpg'):format(url)
    end,
    getBanner = function(self, productID, url)
      assert(type(productID) == 'string', 'wishlist.platforms.gog_galaxy.init.GOGGalaxy.getBanner')
      assert(type(url) == 'string', 'wishlist.platforms.gog_galaxy.init.GOGGalaxy.getBanner')
      local banner = self:getBannerPath(productID)
      if not (banner) then
        local bannerURL = self:generateBannerURL(url)
        banner = io.joinPaths(self.cachePath, ('%s.jpg'):format(productID))
        local expectedBanner = productID
        return banner, bannerURL, expectedBanner
      end
      return banner, nil, nil
    end,
    generateStoreURL = function(self, url)
      return ('https://gog.com%s'):format(url)
    end,
    generateClientCommand = function(self, id)
      return ('\"%s\" \"/command=runGame\" \"/gameID=%d\"'):format(self.clientPath, id)
    end,
    parseWishlist = function(self, html)
      local games = html:match('var gogData = {(.-)};')
      if games ~= nil then
        games = json.decode(('{%s}'):format(games)).products
      end
      if games == nil then
        return 
      end
      for _index_0 = 1, #games do
        local game = games[_index_0]
        local title = utility.adjustTitle(game.title)
        local banner, bannerURL, expectedBanner = self:getBanner(tostring(game.id), game.image)
        local basePrice = tonumber(game.price.baseAmount) or 0
        local finalPrice = tonumber(game.price.finalAmount) or 0
        local discountPercentage = game.price.discountPercentage or 0
        local isFree
        if game.price.isFree == true then
          isFree = true
        else
          isFree = nil
        end
        local isPrerelease
        if game.isComingSoon == true then
          isPrerelease = true
        else
          isPrerelease = nil
        end
        table.insert(self.games, {
          title = title,
          banner = banner,
          bannerURL = bannerURL,
          expectedBanner = expectedBanner,
          url = self:generateStoreURL(game.url),
          clientCommand = self:generateClientCommand(game.id),
          basePrice = basePrice,
          finalPrice = finalPrice,
          discountPercentage = discountPercentage,
          isFree = isFree,
          isPrerelease = isPrerelease,
          platformID = self.platformID
        })
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = self.games
        for _index_0 = 1, #_list_0 do
          local args = _list_0[_index_0]
          _accum_0[_len_0] = Game(args)
          _len_0 = _len_0 + 1
        end
        self.games = _accum_0
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, settings)
      _class_0.__parent.__init(self, settings)
      self.platformID = ENUMS.PLATFORM_IDS.GOG_GALAXY
      self.name = 'GOG Galaxy'
      self.cachePath = 'cache\\gog_galaxy\\'
      self.platformProcess = 'GalaxyClient.exe'
      self.enabled = settings:getGOGGalaxyEnabled()
      self.clientPath = settings:getGOGGalaxyClientPath()
      self.communityProfileName = settings:getGOGGalaxyProfileName()
      self.games = { }
    end,
    __base = _base_0,
    __name = "GOGGalaxy",
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
  GOGGalaxy = _class_0
end
return GOGGalaxy
