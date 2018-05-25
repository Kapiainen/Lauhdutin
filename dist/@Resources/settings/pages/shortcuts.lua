local utility = require('shared.utility')
local Page = require('settings.pages.page')
local Settings = require('settings.types')
local Shortcuts
do
  local _class_0
  local _parent_0 = Page
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.title = LOCALIZATION:get('setting_shortcuts_title', 'Windows shortcuts')
      self.settings = {
        Settings.Boolean({
          title = LOCALIZATION:get('button_label_enabled', 'Enabled'),
          tooltip = LOCALIZATION:get('setting_shortcuts_enabled_description', 'If enabled, then Windows shortcuts placed in the designated folder will be included.'),
          toggle = function(self)
            COMPONENTS.SETTINGS:toggleShortcutsEnabled()
            return true
          end,
          getState = function(self)
            return COMPONENTS.SETTINGS:getShortcutsEnabled()
          end
        }),
        Settings.Action({
          title = LOCALIZATION:get('setting_shortcuts_open_folder_title', 'Folder'),
          tooltip = LOCALIZATION:get('setting_shortcuts_open_folder_description', 'Shortcuts and their banners should be placed in this folder. The banners should be named after their corresponding shortcut.'),
          label = LOCALIZATION:get('button_label_open', 'Open'),
          perform = function(self)
            return SKIN:Bang(('[%s]'):format(io.joinPaths(STATE.PATHS.RESOURCES, 'Shortcuts\\')))
          end
        }),
        Settings.Action({
          title = LOCALIZATION:get('button_label_starting_bangs', 'Starting bangs'),
          tooltip = LOCALIZATION:get('setting_shortcuts_starting_bangs_description', 'These Rainmeter bangs are executed just before any Windows shortcut game launches.'),
          label = LOCALIZATION:get('button_label_edit', 'Edit'),
          perform = function(self)
            local path = 'cache\\bangs.txt'
            local bangs = COMPONENTS.SETTINGS:getShortcutsStartingBangs()
            io.writeFile(path, table.concat(bangs, '\n'))
            return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedShortcutsStartingBangs')
          end
        }),
        Settings.Action({
          title = LOCALIZATION:get('button_label_stopping_bangs', 'Stopping bangs'),
          tooltip = LOCALIZATION:get('setting_shortcuts_stopping_bangs_description', 'These Rainmeter bangs are executed just after any Windows shortcut game terminates.'),
          label = LOCALIZATION:get('button_label_edit', 'Edit'),
          perform = function(self)
            local path = 'cache\\bangs.txt'
            local bangs = COMPONENTS.SETTINGS:getShortcutsStoppingBangs()
            io.writeFile(path, table.concat(bangs, '\n'))
            return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedShortcutsStoppingBangs')
          end
        })
      }
    end,
    __base = _base_0,
    __name = "Shortcuts",
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
  Shortcuts = _class_0
end
return Shortcuts
