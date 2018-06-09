OnCommunityProfileDownloaded = function()
  local success, err = pcall(function()
    log('Successfully downloaded Steam community profile')
    utility.stopDownloader()
    local downloadedPath = STATE.PLATFORM_QUEUE[1]:getDownloadedCommunityProfilePath()
    local cachedPath = STATE.PLATFORM_QUEUE[1]:getCachedCommunityProfilePath()
    os.rename(downloadedPath, cachedPath)
    local profile = ''
    if io.fileExists(cachedPath, false) then
      profile = io.readFile(cachedPath, false)
    end
    STATE.PLATFORM_QUEUE[1]:parseCommunityProfile(profile)
    STATE.PLATFORM_QUEUE[1]:getLibraries()
    if STATE.PLATFORM_QUEUE[1]:hasLibrariesToParse() then
      return utility.runCommand(STATE.PLATFORM_QUEUE[1]:getACFs())
    end
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnCommunityProfileDownloadFailed = function()
  local success, err = pcall(function()
    log('Failed to download Steam community profile')
    utility.stopDownloader()
    STATE.PLATFORM_QUEUE[1]:getLibraries()
    if STATE.PLATFORM_QUEUE[1]:hasLibrariesToParse() then
      return utility.runCommand(STATE.PLATFORM_QUEUE[1]:getACFs())
    end
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnGotACFs = function()
  local success, err = pcall(function()
    if not (STATE.PLATFORM_QUEUE[1]:hasGottenACFs()) then
      return utility.runLastCommand()
    end
    log('Dumped list of Steam appmanifests')
    STATE.PLATFORM_QUEUE[1]:generateGames()
    if STATE.PLATFORM_QUEUE[1]:hasLibrariesToParse() then
      return utility.runCommand(STATE.PLATFORM_QUEUE[1]:getACFs())
    end
    STATE.PLATFORM_QUEUE[1]:generateShortcuts()
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
