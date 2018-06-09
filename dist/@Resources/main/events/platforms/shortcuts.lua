OnParsedShortcuts = function()
  local success, err = pcall(function()
    if not (STATE.PLATFORM_QUEUE[1]:hasParsedShortcuts()) then
      return utility.runLastCommand()
    end
    log('Parsed Windows shortcuts')
    local output = ''
    local path = STATE.PLATFORM_QUEUE[1]:getOutputPath()
    if io.fileExists(path) then
      output = io.readFile(path)
    end
    STATE.PLATFORM_QUEUE[1]:generateGames(output)
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
