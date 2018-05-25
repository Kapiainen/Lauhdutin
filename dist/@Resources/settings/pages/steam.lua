local utility = require('shared.utility')
local Page = require('settings.pages.page')
local Settings = require('settings.types')
local state = {
  accounts = { }
}
local getUsers
getUsers = function()
  local path = io.joinPaths(COMPONENTS.SETTINGS:getSteamPath(), 'config\\loginusers.vdf')
  if not (io.fileExists(path, false)) then
    return nil
  end
  local vdf = utility.parseVDF(io.readFile(path, false))
  if vdf == nil or vdf.users == nil then
    return nil
  end
  for communityID, user in pairs(vdf.users) do
    user.personaname = utility.replaceUnsupportedChars(user.personaname)
  end
  return vdf.users
end
local getPersonaName
getPersonaName = function(accountID)
  local path = io.joinPaths(COMPONENTS.SETTINGS:getSteamPath(), 'userdata', accountID, 'config\\localconfig.vdf')
  if not (io.fileExists(path, false)) then
    return nil
  end
  local vdf = utility.parseVDF(io.readFile(path, false))
  local config = vdf.userroamingconfigstore
  if config == nil then
    config = vdf.userlocalconfigstore
  end
  if config == nil then
    return nil
  end
  if config.friends == nil then
    return nil
  end
  return utility.replaceUnsupportedChars(config.friends.personaname)
end
local updateUsers
updateUsers = function()
  state.accounts = { }
  local path = 'cache\\steam\\users.txt'
  if io.fileExists(path) then
    local users = io.readFile(path)
    local accountIDs = users:splitIntoLines()
    users = getUsers()
    for _index_0 = 1, #accountIDs do
      local _continue_0 = false
      repeat
        local accountID = accountIDs[_index_0]
        local personaName = getPersonaName(accountID)
        if personaName == nil then
          _continue_0 = true
          break
        end
        for communityID, user in pairs(users) do
          if user.personaname == personaName then
            table.insert(state.accounts, {
              accountID = accountID,
              communityID = communityID,
              personaName = personaName,
              displayValue = personaName
            })
            users[communityID] = nil
            break
          end
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  if #state.accounts == 0 then
    state.accounts[1] = {
      accountID = '',
      communityID = '',
      personaName = '',
      displayValue = ''
    }
  end
end
local getUserIndex
getUserIndex = function()
  for i, account in ipairs(state.accounts) do
    log('checking account ' .. i .. ': ' .. account.personaName)
    if account.accountID == COMPONENTS.SETTINGS:getSteamAccountID() then
      log('account index is ' .. i)
      return i
    end
  end
  return 1
end
local Steam
do
  local _class_0
  local _parent_0 = Page
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.title = 'Steam'
      updateUsers()
      local steamClientPathDescription = LOCALIZATION:get('setting_steam_client_path_description', 'This should be the folder that contains the Steam client executable.')
      self.settings = {
        Settings.Boolean({
          title = LOCALIZATION:get('button_label_enabled', 'Enabled'),
          tooltip = LOCALIZATION:get('setting_steam_enabled_description', 'If enabled, then games installed via the Steam client will be included. Non-Steam game shortcuts that have been added to Steam will also be included.'),
          toggle = function()
            COMPONENTS.SETTINGS:toggleSteamEnabled()
            return true
          end,
          getState = function()
            return COMPONENTS.SETTINGS:getSteamEnabled()
          end
        }),
        Settings.FolderPath({
          title = LOCALIZATION:get('button_label_client_path', 'Client path'),
          tooltip = steamClientPathDescription,
          getValue = function(self)
            return COMPONENTS.SETTINGS:getSteamPath()
          end,
          setValue = function(self, path)
            return COMPONENTS.SETTINGS:setSteamPath(path)
          end,
          dialogTitle = steamClientPathDescription
        }),
        Settings.Spinner({
          title = LOCALIZATION:get('setting_steam_account_title', 'Account'),
          tooltip = LOCALIZATION:get('setting_steam_account_description', 'Choose the Steam account whose games to get.'),
          index = getUserIndex(),
          setIndex = function(self, index)
            if index < 1 then
              index = #self:getValues()
            elseif index > #self:getValues() then
              index = 1
            end
            self.index = index
            local account = self:getValues()[self.index]
            COMPONENTS.SETTINGS:setSteamAccountID(account.accountID)
            return COMPONENTS.SETTINGS:setSteamCommunityID(account.communityID)
          end,
          getValues = function(self)
            return state.accounts
          end,
          setValues = function(self)
            updateUsers()
            return self:setIndex(getUserIndex())
          end
        }),
        Settings.Boolean({
          title = LOCALIZATION:get('setting_steam_community_profile_title', 'Parse community profile'),
          tooltip = LOCALIZATION:get('setting_steam_community_profile_description', "If enabled, then the Steam community profile will be downloaded and parsed to get:\n- All games associated with the chosen account even if not installed at the moment.\n- The total hours played of each game associated with the chosen account.\n\nRequires that the Game details setting in the Steam profile's privacy settings is set as public."),
          toggle = function()
            COMPONENTS.SETTINGS:toggleSteamParseCommunityProfile()
            return true
          end,
          getState = function()
            return COMPONENTS.SETTINGS:getSteamParseCommunityProfile()
          end
        }),
        Settings.Action({
          title = LOCALIZATION:get('button_label_starting_bangs', 'Starting bangs'),
          tooltip = LOCALIZATION:get('setting_steam_starting_bangs_description', 'These Rainmeter bangs are executed just before any Steam game launches.'),
          label = LOCALIZATION:get('button_label_edit', 'Edit'),
          perform = function(self)
            local path = 'cache\\bangs.txt'
            local bangs = COMPONENTS.SETTINGS:getSteamStartingBangs()
            io.writeFile(path, table.concat(bangs, '\n'))
            return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedSteamStartingBangs')
          end
        }),
        Settings.Action({
          title = LOCALIZATION:get('button_label_stopping_bangs', 'Stopping bangs'),
          tooltip = LOCALIZATION:get('setting_steam_stopping_bangs_description', 'These Rainmeter bangs are executed just after any Steam game terminates.'),
          label = LOCALIZATION:get('button_label_edit', 'Edit'),
          perform = function(self)
            local path = 'cache\\bangs.txt'
            local bangs = COMPONENTS.SETTINGS:getSteamStoppingBangs()
            io.writeFile(path, table.concat(bangs, '\n'))
            return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedSteamStoppingBangs')
          end
        })
      }
    end,
    __base = _base_0,
    __name = "Steam",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Steam = _class_0
end
return Steam
