OnFinishedDetectingPlatformGames = function()
  local success, err = pcall(function()
    log('Finished detecting platform\'s games')
    local platform = table.remove(STATE.PLATFORM_QUEUE, 1)
    local games = platform:getGames()
    log(('Found %d %s games'):format(#games, platform:getName()))
    COMPONENTS.LIBRARY:extend(games)
    for _index_0 = 1, #games do
      local game = games[_index_0]
      if game:getBannerURL() ~= nil then
        if game:getBanner() == nil then
          game:setBannerURL(nil)
        else
          table.insert(STATE.BANNER_QUEUE, game)
        end
      end
    end
    if #STATE.PLATFORM_QUEUE > 0 then
      return startDetectingPlatformGames()
    end
    STATE.PLATFORM_QUEUE = nil
    log(('%d banners to download'):format(#STATE.BANNER_QUEUE))
    if #STATE.BANNER_QUEUE > 0 then
      return startDownloadingBanner()
    end
    return onInitialized()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
require('main.events.platforms.battlenet')
require('main.events.platforms.gog_galaxy')
require('main.events.platforms.shortcuts')
return require('main.events.platforms.steam')
