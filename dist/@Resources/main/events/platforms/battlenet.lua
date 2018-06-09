OnIdentifiedBattlenetFolders = function()
  local success, err = pcall(function()
    if not (STATE.PLATFORM_QUEUE[1]:hasProcessedPath()) then
      return utility.runLastCommand()
    end
    log('Dumped list of folders in a Blizzard Battle.net folder')
    STATE.PLATFORM_QUEUE[1]:generateGames(io.readFile(io.joinPaths(STATE.PLATFORM_QUEUE[1]:getCachePath(), 'output.txt')))
    if STATE.PLATFORM_QUEUE[1]:hasUnprocessedPaths() then
      return utility.runCommand(STATE.PLATFORM_QUEUE[1]:identifyFolders())
    end
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
