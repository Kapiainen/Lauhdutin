local utility = require('shared.utility')
local migrators = {
  {
    version = 1,
    func = function(settings)
      settings.bangs = {
        global = {
          starting = { },
          stopping = { }
        }
      }
      settings.skin = { }
      settings.slots = { }
      settings.layout = { }
      settings.platforms = {
        shortcuts = {
          bangs = {
            starting = { },
            stopping = { }
          }
        },
        steam = {
          bangs = {
            starting = { },
            stopping = { }
          }
        },
        battlenet = {
          bangs = {
            starting = { },
            stopping = { }
          },
          paths = { }
        },
        gogGalaxy = {
          bangs = {
            starting = { },
            stopping = { }
          }
        }
      }
      settings.layout.horizontal = settings.orientation == 'horizontal'
      if settings.layout.horizontal then
        settings.layout.rows = settings.slot_rows_columns
        settings.layout.columns = settings.slot_count_per_row_column
      else
        settings.layout.rows = settings.slot_count_per_row_column
        settings.layout.columns = settings.slot_rows_columns
      end
      settings.orientation = nil
      settings.slot_count_per_row_column = nil
      settings.slot_rows_columns = nil
      local _exp_0 = settings.click_animation
      if 0 == _exp_0 then
        settings.slots.clickAnimation = ENUMS.SLOT_CLICK_ANIMATIONS.NONE
      elseif 1 == _exp_0 then
        settings.slots.clickAnimation = ENUMS.SLOT_CLICK_ANIMATIONS.SHRINK
      elseif 2 == _exp_0 then
        settings.slots.clickAnimation = ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_LEFT
      elseif 3 == _exp_0 then
        settings.slots.clickAnimation = ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_RIGHT
      elseif 4 == _exp_0 then
        settings.slots.clickAnimation = ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_UP
      elseif 5 == _exp_0 then
        settings.slots.clickAnimation = ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_DOWN
      end
      settings.click_animation = nil
      local _exp_1 = settings.hover_animation
      if 0 == _exp_1 then
        settings.slots.hoverAnimation = ENUMS.SLOT_HOVER_ANIMATIONS.NONE
      elseif 1 == _exp_1 then
        settings.slots.hoverAnimation = ENUMS.SLOT_HOVER_ANIMATIONS.ZOOM_IN
      elseif 2 == _exp_1 then
        settings.slots.hoverAnimation = ENUMS.SLOT_HOVER_ANIMATIONS.JIGGLE
      elseif 3 == _exp_1 then
        settings.slots.hoverAnimation = ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_LEFT_RIGHT
      end
      if settings.slots.hoverAnimation == ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_LEFT_RIGHT and not settings.layout.horizontal then
        settings.slots.hoverAnimation = ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_UP_DOWN
      end
      settings.hover_animation = nil
      local _exp_2 = settings.skin_slide_animation_direction
      if 0 == _exp_2 then
        settings.skin.skinAnimation = ENUMS.SKIN_ANIMATIONS.NONE
      elseif 1 == _exp_2 then
        settings.skin.skinAnimation = ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT
      elseif 2 == _exp_2 then
        settings.skin.skinAnimation = ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT
      elseif 3 == _exp_2 then
        settings.skin.skinAnimation = ENUMS.SKIN_ANIMATIONS.SLIDE_UP
      elseif 4 == _exp_2 then
        settings.skin.skinAnimation = ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN
      end
      settings.skin_slide_animation_direction = nil
      settings.slots.overlayEnabled = settings.slot_highlight
      settings.slot_highlight = nil
      local _exp_3 = settings.sortstate
      if 0 == _exp_3 then
        settings.sorting = ENUMS.SORTING_TYPES.ALPHABETICALLY
      elseif 1 == _exp_3 then
        settings.sorting = ENUMS.SORTING_TYPES.LAST_PLAYED
      elseif 2 == _exp_3 then
        settings.sorting = ENUMS.SORTING_TYPES.HOURS_PLAYED
      else
        settings.sorting = ENUMS.SORTING_TYPES.ALPHABETICALLY
      end
      settings.sortstate = nil
      settings.layout.toolbarAtTop = settings.toolbar_position == 0
      settings.toolbar_position = nil
      local _list_0 = settings.start_game_bang:split('%[!')
      for _index_0 = 1, #_list_0 do
        local bang = _list_0[_index_0]
        table.insert(settings.bangs.global.starting, '[!' .. bang)
      end
      settings.start_game_bang = nil
      local _list_1 = settings.stop_game_bang:split('%[!')
      for _index_0 = 1, #_list_1 do
        local bang = _list_1[_index_0]
        table.insert(settings.bangs.global.stopping, '[!' .. bang)
      end
      settings.stop_game_bang = nil
      settings.layout.width = settings.slot_width
      settings.slot_width = nil
      settings.layout.height = settings.slot_height
      settings.slot_height = nil
      settings.platforms.steam.path = settings.steam_path
      settings.steam_path = nil
      settings.platforms.steam.communityID = settings.steam_id64
      settings.steam_id64 = nil
      settings.platforms.steam.accountID = settings.steam_userdataid
      settings.steam_userdataid = nil
      settings.platforms.steam.useCommunityProfile = settings.parse_steam_community_profile
      settings.parse_steam_community_profile = nil
      local _list_2 = settings.battlenet_path:split('|')
      for _index_0 = 1, #_list_2 do
        local path = _list_2[_index_0]
        table.insert(settings.platforms.battlenet.paths, path)
      end
      settings.battlenet_path = nil
      settings.platforms.gogGalaxy.programDataPath = settings.galaxy_path
      settings.galaxy_path = nil
      settings.show_hours_played = nil
      settings.show_platform_running = nil
      settings.slot_background_color = nil
      settings.slot_text_color = nil
      settings.adjust_zpos = nil
      settings.execute_bangs_by_default = nil
      settings.fuzzy_search = nil
      settings.hidden_games = nil
      settings.installed_games = nil
      settings.set_games_to_execute_bangs = nil
      settings.python_path = nil
      settings.steam_personaname = nil
      settings.show_platform = nil
    end
  }
}
local Settings
do
  local _class_0
  local _base_0 = {
    get = function(self)
      return self.settings
    end,
    load = function(self)
      if io.fileExists(self.path) then
        local settings = io.readJSON(self.path)
        local version = settings.version or 0
        if version > 0 then
          settings = settings.settings
        end
        if self:migrate(settings, version) then
          self:save(settings)
        end
        return settings
      end
      self:save(self.defaultSettings)
      return self.defaultSettings
    end,
    reset = function(self)
      self:save(self.defaultSettings)
      self.settings = io.readJSON(self.path)
    end,
    save = function(self, settings)
      if settings == nil then
        settings = self.settings
      end
      return io.writeJSON(self.path, {
        version = self.version,
        settings = settings
      })
    end,
    migrate = function(self, settings, version)
      assert(type(version) == 'number' and version % 1 == 0, 'Expected the settings version number to be an integer.')
      assert(version <= self.version, ('Unsupported settings version. Expected version %d or earlier.'):format(self.version))
      if version == self.version then
        return false
      end
      for _index_0 = 1, #migrators do
        local migrator = migrators[_index_0]
        if version < migrator.version then
          migrator.func(settings)
        end
      end
      local addDefaults
      addDefaults = function(defaults, loaded)
        for key, value in pairs(defaults) do
          if loaded[key] == nil then
            loaded[key] = value
          else
            if type(value) == 'table' and type(loaded[key]) == 'table' then
              addDefaults(value, loaded[key])
            end
          end
        end
      end
      addDefaults(self.defaultSettings, settings)
      return true
    end,
    hasChanged = function(self, oldSettingsTable)
      local check
      check = function(new, old)
        if old == nil then
          return true
        end
        for key, value in pairs(new) do
          if type(value) == 'table' then
            if check(value, old[key]) then
              return true
            end
          else
            if value ~= old[key] then
              return true
            end
          end
        end
        return false
      end
      return check(self.settings, oldSettingsTable)
    end,
    getNumberOfBackups = function(self)
      return self.settings.numberOfBackups or 5
    end,
    setNumberOfBackups = function(self, value)
      if value < 0 then
        return 
      end
      self.settings.numberOfBackups = value
    end,
    getLogging = function(self)
      if self.settings.logging ~= nil then
        return self.settings.logging
      end
      return false
    end,
    toggleLogging = function(self)
      self.settings.logging = not self.settings.logging
    end,
    getSorting = function(self)
      return self.settings.sorting or ENUMS.SORTING_TYPES.ALPHABETICALLY
    end,
    setSorting = function(self, value)
      if value < 1 then
        return 
      end
      self.settings.sorting = value
    end,
    getLocalization = function(self)
      return self.settings.localization or 'English'
    end,
    setLocalization = function(self, str)
      self.settings.localization = str
    end,
    getBangsEnabled = function(self)
      if self.settings.bangs.enabled ~= nil then
        return self.settings.bangs.enabled
      end
      return false
    end,
    toggleBangsEnabled = function(self)
      self.settings.bangs.enabled = not self.settings.bangs.enabled
    end,
    getGlobalStartingBangs = function(self)
      return self.settings.bangs.global.starting or { }
    end,
    setGlobalStartingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.bangs.global.starting = bangs
    end,
    getGlobalStoppingBangs = function(self)
      return self.settings.bangs.global.stopping or { }
    end,
    setGlobalStoppingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.bangs.global.stopping = bangs
    end,
    getLayoutRows = function(self)
      return self.settings.layout.rows or 1
    end,
    setLayoutRows = function(self, value)
      if value < 1 then
        return 
      end
      self.settings.layout.rows = value
    end,
    getLayoutColumns = function(self)
      return self.settings.layout.columns or 6
    end,
    setLayoutColumns = function(self, value)
      if value < 1 then
        return 
      end
      self.settings.layout.columns = value
    end,
    getLayoutWidth = function(self)
      return self.settings.layout.width or 320
    end,
    setLayoutWidth = function(self, value)
      if value < 16 then
        return 
      end
      self.settings.layout.width = value
    end,
    getLayoutHeight = function(self)
      return self.settings.layout.height or 150
    end,
    setLayoutHeight = function(self, value)
      if value < 16 then
        return 
      end
      self.settings.layout.height = value
    end,
    getLayoutHorizontal = function(self)
      if self.settings.layout.horizontal ~= nil then
        return self.settings.layout.horizontal
      end
      return true
    end,
    toggleLayoutHorizontal = function(self)
      self.settings.layout.horizontal = not self.settings.layout.horizontal
    end,
    getLayoutToolbarAtTop = function(self)
      if self.settings.layout.toolbarAtTop ~= nil then
        return self.settings.layout.toolbarAtTop
      end
      return true
    end,
    toggleLayoutToolbarAtTop = function(self)
      self.settings.layout.toolbarAtTop = not self.settings.layout.toolbarAtTop
    end,
    getCenterOnMonitor = function(self)
      if self.settings.layout.centerOnMonitor ~= nil then
        return self.settings.layout.centerOnMonitor
      end
      return true
    end,
    toggleCenterOnMonitor = function(self)
      self.settings.layout.centerOnMonitor = not self.settings.layout.centerOnMonitor
    end,
    getHideSkin = function(self)
      if self.settings.skin.hideWhilePlaying ~= nil then
        return self.settings.skin.hideWhilePlaying
      end
      return false
    end,
    toggleHideSkin = function(self)
      self.settings.skin.hideWhilePlaying = not self.settings.skin.hideWhilePlaying
    end,
    getSkinSlideAnimation = function(self)
      return self.settings.skin.skinAnimation or ENUMS.SKIN_ANIMATIONS.NONE
    end,
    setSkinSlideAnimation = function(self, value)
      if value < ENUMS.SKIN_ANIMATIONS.NONE or value >= ENUMS.SKIN_ANIMATIONS.MAX then
        return 
      end
      self.settings.skin.skinAnimation = value
    end,
    getSkinRevealingDelay = function(self)
      return self.settings.skin.revealingDelay or 500
    end,
    setSkinRevealingDelay = function(self, value)
      if value < 0 then
        return 
      end
      self.settings.skin.revealingDelay = value
    end,
    getScrollStep = function(self)
      return self.settings.skin.scrollStep or 1
    end,
    setScrollStep = function(self, value)
      if value < 1 then
        return 
      end
      self.settings.skin.scrollStep = value
    end,
    getDoubleClickToLaunch = function(self)
      if self.settings.slots.doubleClickToLaunch ~= nil then
        return self.settings.slots.doubleClickToLaunch
      end
      return false
    end,
    toggleDoubleClickToLaunch = function(self)
      self.settings.slots.doubleClickToLaunch = not self.settings.slots.doubleClickToLaunch
    end,
    getSlotsOverlayEnabled = function(self)
      if self.settings.slots.overlayEnabled ~= nil then
        return self.settings.slots.overlayEnabled
      end
      return true
    end,
    toggleSlotsOverlayEnabled = function(self)
      self.settings.slots.overlayEnabled = not self.settings.slots.overlayEnabled
    end,
    getSlotsHoverAnimation = function(self)
      return self.settings.slots.hoverAnimation or ENUMS.SLOT_HOVER_ANIMATIONS.ZOOM_IN
    end,
    setSlotsHoverAnimation = function(self, value)
      if value < ENUMS.SLOT_HOVER_ANIMATIONS.NONE or value >= ENUMS.SLOT_HOVER_ANIMATIONS.MAX then
        return 
      end
      self.settings.slots.hoverAnimation = value
    end,
    getSlotsClickAnimation = function(self)
      return self.settings.slots.clickAnimation or ENUMS.SLOT_CLICK_ANIMATIONS.SHRINK
    end,
    setSlotsClickAnimation = function(self, value)
      if value < ENUMS.SLOT_CLICK_ANIMATIONS.NONE or value >= ENUMS.SLOT_CLICK_ANIMATIONS.MAX then
        return 
      end
      self.settings.slots.clickAnimation = value
    end,
    getShortcutsEnabled = function(self)
      if self.settings.platforms.shortcuts.enabled ~= nil then
        return self.settings.platforms.shortcuts.enabled
      end
      return false
    end,
    toggleShortcutsEnabled = function(self)
      self.settings.platforms.shortcuts.enabled = not self.settings.platforms.shortcuts.enabled
    end,
    getShortcutsStartingBangs = function(self)
      return self.settings.platforms.shortcuts.bangs.starting or { }
    end,
    setShortcutsStartingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.platforms.shortcuts.bangs.starting = bangs
    end,
    getShortcutsStoppingBangs = function(self)
      return self.settings.platforms.shortcuts.bangs.stopping or { }
    end,
    setShortcutsStoppingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.platforms.shortcuts.bangs.stopping = bangs
    end,
    getSteamEnabled = function(self)
      if self.settings.platforms.steam.enabled ~= nil then
        return self.settings.platforms.steam.enabled
      end
      return false
    end,
    toggleSteamEnabled = function(self)
      self.settings.platforms.steam.enabled = not self.settings.platforms.steam.enabled
    end,
    getSteamPath = function(self)
      return self.settings.platforms.steam.path or nil
    end,
    setSteamPath = function(self, path)
      if not (io.fileExists(io.joinPaths(path, 'Steam.exe'), false)) then
        return false
      end
      self.settings.platforms.steam.path = path
      SKIN:Bang(('["#@#windowless.vbs" "#@#settings\\platforms\\steam\\listUsers.bat" "%s"]'):format(io.joinPaths(path, 'userdata')))
      utility.runCommand(utility.waitCommand, '', 'OnSteamUsersListed')
      return true
    end,
    getSteamAccountID = function(self)
      return self.settings.platforms.steam.accountID or nil
    end,
    setSteamAccountID = function(self, value)
      self.settings.platforms.steam.accountID = value
    end,
    getSteamCommunityID = function(self)
      return self.settings.platforms.steam.communityID or nil
    end,
    setSteamCommunityID = function(self, value)
      self.settings.platforms.steam.communityID = value
    end,
    getSteamParseCommunityProfile = function(self)
      if self.settings.platforms.steam.useCommunityProfile ~= nil then
        return self.settings.platforms.steam.useCommunityProfile
      end
      return false
    end,
    toggleSteamParseCommunityProfile = function(self)
      self.settings.platforms.steam.useCommunityProfile = not self.settings.platforms.steam.useCommunityProfile
    end,
    getSteamStartingBangs = function(self)
      return self.settings.platforms.steam.bangs.starting or { }
    end,
    setSteamStartingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.platforms.steam.bangs.starting = bangs
    end,
    getSteamStoppingBangs = function(self)
      return self.settings.platforms.steam.bangs.stopping or { }
    end,
    setSteamStoppingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.platforms.steam.bangs.stopping = bangs
    end,
    getBattlenetEnabled = function(self)
      return self.settings.platforms.battlenet.enabled or false
    end,
    toggleBattlenetEnabled = function(self)
      self.settings.platforms.battlenet.enabled = not self.settings.platforms.battlenet.enabled
    end,
    getBattlenetPaths = function(self)
      return self.settings.platforms.battlenet.paths or { }
    end,
    setBattlenetPath = function(self, index, path)
      if path == '' then
        return table.remove(self.settings.platforms.battlenet.paths, index)
      else
        self.settings.platforms.battlenet.paths[index] = path
      end
    end,
    getBattlenetStartingBangs = function(self)
      return self.settings.platforms.battlenet.bangs.starting or { }
    end,
    setBattlenetStartingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.platforms.battlenet.bangs.starting = bangs
    end,
    getBattlenetStoppingBangs = function(self)
      return self.settings.platforms.battlenet.bangs.stopping or { }
    end,
    setBattlenetStoppingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.platforms.battlenet.bangs.stopping = bangs
    end,
    getGOGGalaxyEnabled = function(self)
      return self.settings.platforms.gogGalaxy.enabled or false
    end,
    toggleGOGGalaxyEnabled = function(self)
      self.settings.platforms.gogGalaxy.enabled = not self.settings.platforms.gogGalaxy.enabled
    end,
    getGOGGalaxyClientPath = function(self)
      return self.settings.platforms.gogGalaxy.clientPath or nil
    end,
    setGOGGalaxyClientPath = function(self, path)
      if not (io.fileExists(io.joinPaths(path, 'GalaxyClient.exe'), false)) then
        return false
      end
      self.settings.platforms.gogGalaxy.clientPath = path
      return true
    end,
    getGOGGalaxyProgramDataPath = function(self)
      return self.settings.platforms.gogGalaxy.programDataPath or nil
    end,
    setGOGGalaxyProgramDataPath = function(self, path)
      if not (io.fileExists(io.joinPaths(path, 'storage\\index.db'), false)) then
        return false
      end
      self.settings.platforms.gogGalaxy.programDataPath = path
      return true
    end,
    getGOGGalaxyIndirectLaunch = function(self)
      return self.settings.platforms.gogGalaxy.indirectLaunch or false
    end,
    toggleGOGGalaxyIndirectLaunch = function(self)
      self.settings.platforms.gogGalaxy.indirectLaunch = not self.settings.platforms.gogGalaxy.indirectLaunch
    end,
    getGOGGalaxyStartingBangs = function(self)
      return self.settings.platforms.gogGalaxy.bangs.starting or { }
    end,
    setGOGGalaxyStartingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.platforms.gogGalaxy.bangs.starting = bangs
    end,
    getGOGGalaxyStoppingBangs = function(self)
      return self.settings.platforms.gogGalaxy.bangs.stopping or { }
    end,
    setGOGGalaxyStoppingBangs = function(self, tbl)
      local bangs = { }
      for _index_0 = 1, #tbl do
        local bang = tbl[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(bangs, bang)
        end
      end
      self.settings.platforms.gogGalaxy.bangs.stopping = bangs
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.version = 1
      self.path = 'settings.json'
      self.defaultSettings = {
        numberOfBackups = 5,
        logging = false,
        sorting = ENUMS.SORTING_TYPES.ALPHABETICALLY,
        bangs = {
          enabled = true,
          global = {
            starting = { },
            stopping = { }
          }
        },
        layout = {
          rows = 1,
          columns = 4,
          width = 320,
          height = 150,
          horizontal = true,
          toolbarAtTop = true,
          centerOnMonitor = true
        },
        skin = {
          hideWhilePlaying = true,
          skinAnimation = ENUMS.SKIN_ANIMATIONS.NONE,
          revealingDelay = 0,
          scrollStep = 1
        },
        slots = {
          doubleClickToLaunch = false,
          overlayEnabled = true,
          hoverAnimation = ENUMS.SLOT_HOVER_ANIMATIONS.ZOOM_IN,
          clickAnimation = ENUMS.SLOT_CLICK_ANIMATIONS.SHRINK
        },
        platforms = {
          shortcuts = {
            enabled = false,
            bangs = {
              starting = { },
              stopping = { }
            }
          },
          steam = {
            enabled = false,
            bangs = {
              starting = { },
              stopping = { }
            },
            path = '',
            accountID = '',
            communityID = '',
            useCommunityProfile = false
          },
          battlenet = {
            enabled = false,
            bangs = {
              starting = { },
              stopping = { }
            },
            paths = { }
          },
          gogGalaxy = {
            enabled = false,
            bangs = {
              starting = { },
              stopping = { }
            },
            clientPath = '',
            programDataPath = 'C:\\ProgramData\\GOG.com\\Galaxy',
            indirectLaunch = false
          }
        }
      }
      self.settings = self:load()
    end,
    __base = _base_0,
    __name = "Settings"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Settings = _class_0
end
return Settings
