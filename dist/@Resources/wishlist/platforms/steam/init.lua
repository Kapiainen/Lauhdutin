local Platform = require('wishlist.platforms.platform')
local Steam
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    validate = function(self)
      local clientPath = io.joinPaths(self.steamPath, 'steam.exe')
      assert(io.fileExists(clientPath, false), 'The Steam path is not valid.')
      assert(self.communityID ~= nil, 'A Steam ID has not been provided for downloading the community profile.')
      return assert(tonumber(self.communityID) ~= nil, 'The Steam ID is invalid.')
    end,
    getWishlistURL = function(self)
      return ('https://store.steampowered.com/wishlist/profiles/%s'):format(self.communityID), 'wishlist.txt', 'OnSteamWishlistDownloaded', 'OnSteamWishlistDownloadFailed'
    end,
    generateStoreURL = function(self, appID)
      return ('https://store.steampowered.com/app/%s'):format(appID)
    end,
    generateClientCommand = function(self, appID)
      return ('steam://store/%s'):format(appID)
    end,
    generateBannerURL = function(self, appID)
      return ('http://cdn.akamai.steamstatic.com/steam/apps/%s/header.jpg'):format(appID)
    end,
    getBanner = function(self, appID)
      assert(type(appID) == 'string', 'wishlist.platforms.steam.init.Steam.getBanner')
      local banner = self:getBannerPath(appID)
      if not (banner) then
        banner = io.joinPaths(self.cachePath, appID .. '.jpg')
        local bannerURL = self:generateBannerURL(appID)
        local expectedBanner = appID
        return banner, bannerURL, expectedBanner
      end
      return banner, nil, nil
    end,
    getPricesDiscountCurrency = function(self, subs)
      local base = nil
      local final = nil
      local discount = nil
      for _index_0 = 1, #subs do
        local sub = subs[_index_0]
        local b = sub.discount_block:match('original_price\">(%d+[,%.]%d+)')
        local f = sub.discount_block:match('final_price\">(%d+[,%.]%d+)')
        if f ~= nil then
          f = tonumber((f:gsub(',', '.')))
        end
        if b ~= nil then
          b = tonumber((b:gsub(',', '.')))
        else
          b = f
        end
        if final == nil or (f ~= nil and f < final) then
          base, final, discount = b, f, sub.discount_pct
        end
      end
      return base, final, discount
    end,
    parseWishlist = function(self, html)
      local games = html:match('var g_rgAppInfo = {(.-)};')
      if games ~= nil then
        games = json.decode(('{%s}'):format(games))
      end
      if games == nil then
        return 
      end
      for appID, game in pairs(games) do
        local title = utility.adjustTitle(game.name)
        local banner, bannerURL, expectedBanner = self:getBanner(appID)
        local basePrice, finalPrice, discountPercentage = self:getPricesDiscountCurrency(game.subs)
        local isFree
        if game.free ~= nil then
          isFree = game.free == 1
        else
          isFree = nil
        end
        local isPrerelease
        if game.prerelease ~= nil then
          isPrerelease = game.prerelease == 1
        else
          isPrerelease = nil
        end
        table.insert(self.games, {
          title = title,
          banner = banner,
          bannerURL = bannerURL,
          expectedBanner = expectedBanner,
          url = self:generateStoreURL(appID),
          clientCommand = self:generateClientCommand(appID),
          basePrice = basePrice or 0,
          finalPrice = finalPrice or 0,
          discountPercentage = discountPercentage or 0,
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
      self.platformID = ENUMS.PLATFORM_IDS.STEAM
      self.name = "Steam"
      self.cachePath = 'cache\\steam\\'
      self.platformProcess = 'Steam.exe'
      self.enabled = settings:getSteamEnabled()
      self.steamPath = settings:getSteamPath()
      self.communityID = settings:getSteamCommunityID()
      self.games = { }
    end,
    __base = _base_0,
    __name = "Steam",
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
  Steam = _class_0
end
return Steam
