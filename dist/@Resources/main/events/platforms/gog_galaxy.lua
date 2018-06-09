OnDownloadedGOGCommunityProfile = function()
  local success, err = pcall(function()
    if not (STATE.PLATFORM_QUEUE[1]:hasdownloadedCommunityProfile()) then
      return utility.runLastCommand()
    end
    log('Downloaded GOG community profile')
    return utility.runCommand(STATE.PLATFORM_QUEUE[1]:dumpDatabases())
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnDumpedDBs = function()
  local success, err = pcall(function()
    if not (STATE.PLATFORM_QUEUE[1]:hasDumpedDatabases()) then
      return utility.runLastCommand()
    end
    log('Dumped GOG Galaxy databases')
    local cachePath = STATE.PLATFORM_QUEUE[1]:getCachePath()
    local index = io.readFile(io.joinPaths(cachePath, 'index.txt'))
    local galaxyPath = io.joinPaths(cachePath, 'galaxy.txt')
    local galaxy = io.readFile(galaxyPath)
    local newGalaxy = { }
    local wholeLine = { }
    local lines = galaxy:splitIntoLines()
    for _index_0 = 1, #lines do
      local line = lines[_index_0]
      if line:match('^%d+|[^|]+|[^|]+|.+$') then
        table.insert(newGalaxy, table.concat(wholeLine, ''))
        wholeLine = { }
      end
      table.insert(wholeLine, line)
    end
    if #wholeLine > 0 then
      table.insert(newGalaxy, table.concat(wholeLine, ''))
    end
    galaxy = table.concat(newGalaxy, '\n')
    io.writeFile(galaxyPath, galaxy)
    local profilePath = io.joinPaths(cachePath, 'profile.txt')
    local profile
    if io.fileExists(profilePath) then
      profile = io.readFile(profilePath)
    else
      profile = nil
    end
    STATE.PLATFORM_QUEUE[1]:generateGames(index, galaxy, profile)
    return OnFinishedDetectingPlatformGames()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
