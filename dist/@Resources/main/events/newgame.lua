StartAddingGame = function()
  local success, err = pcall(function()
    return SKIN:Bang('[!ActivateConfig "#ROOTCONFIG#\\NewGame"]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
HandshakeNewGame = function()
  local success, err = pcall(function()
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\NewGame"]'):format(COMPONENTS.LIBRARY:getNextAvailableGameID()))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnAddGame = function(gameID)
  local success, err = pcall(function()
    local game = getGameByID(gameID)
    assert(game ~= nil, 'main.init.OnAddGame')
    return COMPONENTS.LIBRARY:insert(game)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
