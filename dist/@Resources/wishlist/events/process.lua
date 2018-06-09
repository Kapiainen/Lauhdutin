local getGameByID
getGameByID = function(gameID)
  local games = io.readJSON(STATE.PATHS.GAMES)
  games = games.games
  local game = games[gameID]
  if game == nil or game.gameID ~= gameID then
    game = nil
    for _index_0 = 1, #games do
      local args = games[_index_0]
      if args.gameID == gameID then
        game = args
        break
      end
    end
  end
  if game == nil then
    log('Failed to get game by gameID:', gameID)
    return nil
  end
  return Game(game)
end
local getPlatformByGame
getPlatformByGame = function(game)
  local platforms
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = require('wishlist.platforms')
    for _index_0 = 1, #_list_0 do
      local Platform = _list_0[_index_0]
      _accum_0[_len_0] = Platform(COMPONENTS.SETTINGS)
      _len_0 = _len_0 + 1
    end
    platforms = _accum_0
  end
  local platformID = game:getPlatformID()
  for _index_0 = 1, #platforms do
    local platform = platforms[_index_0]
    if platform:getPlatformID() == platformID then
      return platform
    end
  end
  log("Failed to get platform based on the game", platformID)
  return nil
end
UpdatePlatformProcesses = function(gameID)
  local success, err = pcall(function()
    local game = getGameByID(tonumber(gameID))
    if game == nil then
      return 
    end
    local platform = getPlatformByGame(game)
    if platform ~= nil and COMPONENTS.PROCESS:isPlatformRunning(platform) then
      return SKIN:Bang(game:getClientCommand())
    end
    return SKIN:Bang(game:getURL())
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
