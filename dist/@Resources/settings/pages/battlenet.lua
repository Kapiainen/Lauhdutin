local utility = require('shared.utility')
local Page = require('settings.pages.page')
local Settings = require('settings.types')
local state = {
  paths = COMPONENTS.SETTINGS:getBattlenetPaths()
}
local Battlenet
do
  local _class_0
  local _parent_0 = Page
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.title = 'Blizzard Battle.net'
      self.settings = {
        Settings.Boolean({
          title = LOCALIZATION:get('button_label_enabled', 'Enabled'),
          tooltip = LOCALIZATION:get('setting_battlenet_enabled_description', 'If enabled, then games installed via the Blizzard Battle.net client will be included.'),
          toggle = function()
            COMPONENTS.SETTINGS:toggleBattlenetEnabled()
            return true
          end,
          getState = function()
            return COMPONENTS.SETTINGS:getBattlenetEnabled()
          end
        }),
        Settings.FolderPathSpinner({
          title = LOCALIZATION:get('setting_battlenet_paths_title', 'Paths'),
          tooltip = LOCALIZATION:get('setting_battlenet_paths_description', '""Define the absolute paths to folders, which contain Blizzard Battle.net games in their own subfolders:\nIf e.g. Hearthstone is installed in "D:\\Blizzard games\\Hearthstone", then the path that you give should be "D:\\Blizzard games".\nEdit a path and input an empty string to remove that path.""'),
          index = 1,
          getValues = function(self)
            local values
            do
              local _accum_0 = { }
              local _len_0 = 1
              local _list_0 = state.paths
              for _index_0 = 1, #_list_0 do
                local path = _list_0[_index_0]
                _accum_0[_len_0] = path
                _len_0 = _len_0 + 1
              end
              values = _accum_0
            end
            table.insert(values, LOCALIZATION:get('setting_battlenet_add_path', 'Add path...'))
            return values
          end,
          setValues = function(self, values)
            self.values = values
            return self:setIndex(self.index)
          end,
          setPath = function(self, index, path)
            COMPONENTS.SETTINGS:setBattlenetPath(index, path)
            return self:setValues(COMPONENTS.SETTINGS:getBattlenetPaths())
          end
        }),
        Settings.Action({
          title = LOCALIZATION:get('button_label_starting_bangs', 'Starting bangs'),
          tooltip = LOCALIZATION:get('setting_battlenet_starting_bangs_description', 'These Rainmeter bangs are executed just before any Blizzard Battle.net game launches.'),
          label = LOCALIZATION:get('button_label_edit', 'Edit'),
          perform = function(self)
            local path = 'cache\\bangs.txt'
            local bangs = COMPONENTS.SETTINGS:getBattlenetStartingBangs()
            io.writeFile(path, table.concat(bangs, '\n'))
            return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedBattlenetStartingBangs')
          end
        }),
        Settings.Action({
          title = LOCALIZATION:get('button_label_stopping_bangs', 'Stopping bangs'),
          tooltip = LOCALIZATION:get('setting_battlenet_stopping_bangs_description', 'These Rainmeter bangs are executed just after any Blizzard Battle.net game terminates.'),
          label = LOCALIZATION:get('button_label_edit', 'Edit'),
          perform = function(self)
            local path = 'cache\\bangs.txt'
            local bangs = COMPONENTS.SETTINGS:getBattlenetStoppingBangs()
            io.writeFile(path, table.concat(bangs, '\n'))
            return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedBattlenetStoppingBangs')
          end
        })
      }
    end,
    __base = _base_0,
    __name = "Battlenet",
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
  Battlenet = _class_0
end
return Battlenet
