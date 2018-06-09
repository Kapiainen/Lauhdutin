require('main.events.skin')
Unload = nil
TriggerGameDetection = nil
ToggleHideGames = nil
ToggleUnhideGames = nil
ToggleRemoveGames = nil
Refresh = function()
  local success, err = pcall(function()
    local games = io.readJSON(STATE.PATHS.GAMES)
    games.updated = nil
    io.writeJSON(STATE.PATHS.GAMES, games)
    return SKIN:Bang("[!Refresh]")
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
