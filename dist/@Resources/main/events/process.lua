UpdateProcess = function(running)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    return COMPONENTS.PROCESS:update(running == 1)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
UpdatePlatformProcesses = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    STATE.PLATFORM_RUNNING_STATUS = COMPONENTS.PROCESS:updatePlatforms()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
GameProcessStarted = function(game)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('Game started')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
GameProcessTerminated = function(game)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    local duration = COMPONENTS.PROCESS:getDuration() / 3600
    log(game:getTitle(), 'was played for', duration, 'hours')
    game:incrementHoursPlayed(duration)
    COMPONENTS.LIBRARY:save()
    local platformID = game:getPlatformID()
    if COMPONENTS.SETTINGS:getBangsEnabled() then
      if not (game:getIgnoresOtherBangs()) then
        local _list_0 = COMPONENTS.SETTINGS:getGlobalStoppingBangs()
        for _index_0 = 1, #_list_0 do
          local bang = _list_0[_index_0]
          SKIN:Bang(bang)
        end
        local platformBangs
        local _exp_0 = platformID
        if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getShortcutsStoppingBangs()
        elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 or ENUMS.PLATFORM_IDS.STEAM_SHORTCUTS == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getSteamStoppingBangs()
        elseif ENUMS.PLATFORM_IDS.BATTLENET == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getBattlenetStoppingBangs()
        elseif ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getGOGGalaxyStoppingBangs()
        elseif ENUMS.PLATFORM_IDS.CUSTOM == _exp_0 then
          platformBangs = COMPONENTS.SETTINGS:getCustomStoppingBangs()
        else
          platformBangs = assert(nil, 'Encountered an unsupported platform ID when executing platform-specific stopping bangs.')
        end
        for _index_0 = 1, #platformBangs do
          local bang = platformBangs[_index_0]
          SKIN:Bang(bang)
        end
      end
      local _list_0 = game:getStoppingBangs()
      for _index_0 = 1, #_list_0 do
        local bang = _list_0[_index_0]
        SKIN:Bang(bang)
      end
    end
    local _exp_0 = platformID
    if ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
      if COMPONENTS.SETTINGS:getGOGGalaxyIndirectLaunch() then
        SKIN:Bang('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\closeClient.bat"]')
      end
    end
    if COMPONENTS.SETTINGS:getHideSkin() then
      SKIN:Bang('[!ShowFade]')
    end
    if COMPONENTS.SETTINGS:getShowSession() then
      return SKIN:Bang(('[!DeactivateConfig "%s"]'):format(('%s\\Session'):format(STATE.ROOT_CONFIG)))
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
ManuallyTerminateGameProcess = function()
  local success, err = pcall(function()
    return COMPONENTS.PROCESS:stopMonitoring()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
