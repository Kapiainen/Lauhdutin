local utility = require('shared.utility')
local Page = require('settings.pages.page')
local Settings = require('settings.types')
local state = {
  languages = { }
}
local updateLanguages
updateLanguages = function()
  local path = 'cache\\languages.txt'
  state.languages = { }
  if io.fileExists(path) then
    local file = io.readFile(path)
    local _list_0 = file:splitIntoLines()
    for _index_0 = 1, #_list_0 do
      local _continue_0 = false
      repeat
        local line = _list_0[_index_0]
        if not (line:endsWith('%.txt')) then
          _continue_0 = true
          break
        end
        if line == 'languages.txt' then
          _continue_0 = true
          break
        end
        local language = line:match('([^%.]+)')
        table.insert(state.languages, {
          displayValue = language
        })
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  local englishListed = false
  local _list_0 = state.languages
  for _index_0 = 1, #_list_0 do
    local language = _list_0[_index_0]
    if language.displayValue == 'English' then
      englishListed = true
      break
    end
  end
  if not (englishListed) then
    table.insert(state.languages, {
      displayValue = 'English'
    })
  end
  return table.sort(state.languages, function(a, b)
    if a.displayValue:lower() < b.displayValue:lower() then
      return true
    end
    return false
  end)
end
local getLanguageIndex
getLanguageIndex = function()
  local currentLanguage = COMPONENTS.SETTINGS:getLocalization()
  for i, language in ipairs(state.languages) do
    if language.displayValue == currentLanguage then
      return i
    end
  end
  return 1
end
state.slotHoverAnimations = {
  {
    displayValue = LOCALIZATION:get('setting_animation_label_none', 'None')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_zoom_in', 'Zoom in')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_jiggle', 'Jiggle')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_shake_left_right', 'Shake left and right')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_shake_up_down', 'Shake up and down')
  }
}
state.slotClickAnimations = {
  {
    displayValue = LOCALIZATION:get('setting_animation_label_none', 'None')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_slide_up', 'Slide upwards')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_slide_right', 'Slide to the right')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_slide_down', 'Slide downwards')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_slide_left', 'Slide to the left')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_shrink', 'Shrink')
  }
}
state.skinAnimations = {
  {
    displayValue = LOCALIZATION:get('setting_animation_label_none', 'None')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_slide_up', 'Slide upwards')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_slide_right', 'Slide to the right')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_slide_down', 'Slide downwards')
  },
  {
    displayValue = LOCALIZATION:get('setting_animation_label_slide_left', 'Slide to the left')
  }
}
local Skin
do
  local _class_0
  local _parent_0 = Page
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.title = LOCALIZATION:get('setting_skin_title', 'Skin')
      updateLanguages()
      self.settings = {
        Settings.Boolean({
          title = LOCALIZATION:get('setting_slots_horizontal_orientation_title', 'Horizontal orientation'),
          tooltip = LOCALIZATION:get('setting_slots_horizontal_orientation_description', 'If enabled, then slots are placed from left to right. If disabled, then slots are placed from the top to the bottom.'),
          toggle = function()
            COMPONENTS.SETTINGS:toggleLayoutHorizontal()
            return true
          end,
          getState = function()
            return COMPONENTS.SETTINGS:getLayoutHorizontal()
          end
        }),
        Settings.Integer({
          title = LOCALIZATION:get('setting_slots_rows_title', 'Number of rows'),
          tooltip = LOCALIZATION:get('setting_slots_rows_description', 'The number of rows of slots.'),
          defaultValue = COMPONENTS.SETTINGS:getLayoutRows(),
          minValue = 1,
          maxValue = 16,
          onValueChanged = function(self, value)
            return COMPONENTS.SETTINGS:setLayoutRows(value)
          end
        }),
        Settings.Integer({
          title = LOCALIZATION:get('setting_slots_columns_title', 'Number of columns'),
          tooltip = LOCALIZATION:get('setting_slots_columns_description', 'The number of columns of slots.'),
          defaultValue = COMPONENTS.SETTINGS:getLayoutColumns(),
          minValue = 1,
          maxValue = 16,
          onValueChanged = function(self, value)
            return COMPONENTS.SETTINGS:setLayoutColumns(value)
          end
        }),
        Settings.Integer({
          title = LOCALIZATION:get('setting_slots_width_title', 'Slot width'),
          tooltip = LOCALIZATION:get('setting_slots_width_description', 'The width of each slot in pixels.'),
          defaultValue = COMPONENTS.SETTINGS:getLayoutWidth(),
          minValue = 144,
          maxValue = 1280,
          onValueChanged = function(self, value)
            return COMPONENTS.SETTINGS:setLayoutWidth(value)
          end
        }),
        Settings.Integer({
          title = LOCALIZATION:get('setting_slots_height_title', 'Slot height'),
          tooltip = LOCALIZATION:get('setting_slots_height_description', 'The height of each slot in pixels.'),
          defaultValue = COMPONENTS.SETTINGS:getLayoutHeight(),
          minValue = 48,
          maxValue = 600,
          onValueChanged = function(self, value)
            return COMPONENTS.SETTINGS:setLayoutHeight(value)
          end
        }),
        Settings.Boolean({
          title = LOCALIZATION:get('setting_slots_overlay_enabled_title', 'Show overlay on slots'),
          tooltip = LOCALIZATION:get('setting_slots_overlay_enabled_description', 'If enabled, then an overlay with contextual information is displayed when the mouse is on a slot.'),
          toggle = function()
            COMPONENTS.SETTINGS:toggleSlotsOverlayEnabled()
            return true
          end,
          getState = function()
            return COMPONENTS.SETTINGS:getSlotsOverlayEnabled()
          end
        }),
        Settings.Spinner({
          title = LOCALIZATION:get('setting_slots_hover_animation_title', 'Slot hover animation'),
          tooltip = LOCALIZATION:get('setting_slots_hover_animation_description', 'The animation that plays when the mouse is on a slot.'),
          index = COMPONENTS.SETTINGS:getSlotsHoverAnimation(),
          setIndex = function(self, index)
            if index < 1 then
              index = #self:getValues()
            elseif index > #self:getValues() then
              index = 1
            end
            self.index = index
            return COMPONENTS.SETTINGS:setSlotsHoverAnimation(index)
          end,
          getValues = function(self)
            return state.slotHoverAnimations
          end,
          setValues = function(self) end
        }),
        Settings.Spinner({
          title = LOCALIZATION:get('setting_slots_click_animation_title', 'Slot click animation'),
          tooltip = LOCALIZATION:get('setting_slots_click_animation_description', 'The animation that plays when a slot is clicked.'),
          index = COMPONENTS.SETTINGS:getSlotsClickAnimation(),
          setIndex = function(self, index)
            if index < 1 then
              index = #self:getValues()
            elseif index > #self:getValues() then
              index = 1
            end
            self.index = index
            return COMPONENTS.SETTINGS:setSlotsClickAnimation(index)
          end,
          getValues = function(self)
            return state.slotClickAnimations
          end,
          setValues = function(self) end
        }),
        Settings.Boolean({
          title = LOCALIZATION:get('setting_slots_double_click_to_launch_title', 'Double-click to launch.'),
          tooltip = LOCALIZATION:get('setting_slots_double_click_to_launch_description', 'If enabled, then a game has to be double-clicked to launched.'),
          toggle = function()
            COMPONENTS.SETTINGS:toggleDoubleClickToLaunch()
            return true
          end,
          getState = function()
            return COMPONENTS.SETTINGS:getDoubleClickToLaunch()
          end
        }),
        Settings.Spinner({
          title = LOCALIZATION:get('setting_skin_animation_title', 'Skin animation'),
          tooltip = LOCALIZATION:get('setting_skin_animation_description', 'The animation that is played when the mouse leaves the skin. The animation is played in reverse when the mouse enters the skin\'s enabler edge.'),
          index = COMPONENTS.SETTINGS:getSkinSlideAnimation(),
          setIndex = function(self, index)
            if index < 1 then
              index = #self:getValues()
            elseif index > #self:getValues() then
              index = 1
            end
            self.index = index
            return COMPONENTS.SETTINGS:setSkinSlideAnimation(index)
          end,
          getValues = function(self)
            return state.skinAnimations
          end,
          setValues = function(self) end
        }),
        Settings.Integer({
          title = LOCALIZATION:get('setting_skin_revealing_delay_title', 'Revealing delay'),
          tooltip = LOCALIZATION:get('setting_skin_revealing_delay_description', 'The duration (in milliseconds) before the skin animation is played in order to reveal the skin.'),
          defaultValue = COMPONENTS.SETTINGS:getSkinRevealingDelay(),
          minValue = 0,
          maxValue = 10000,
          stepValue = 16,
          onValueChanged = function(self, value)
            return COMPONENTS.SETTINGS:setSkinRevealingDelay(value)
          end
        }),
        Settings.Integer({
          title = LOCALIZATION:get('setting_skin_scroll_step_title', 'Scroll step'),
          tooltip = LOCALIZATION:get('setting_skin_scroll_step_description', 'The number of games that are scrolled at each scroll event.'),
          defaultValue = COMPONENTS.SETTINGS:getScrollStep(),
          minValue = 1,
          maxValue = 100,
          onValueChanged = function(self, value)
            return COMPONENTS.SETTINGS:setScrollStep(value)
          end
        }),
        Settings.Boolean({
          title = LOCALIZATION:get('setting_slots_toolbar_at_top_title', 'Toolbar at the top'),
          tooltip = LOCALIZATION:get('setting_slots_toolbar_at_top_description', 'If enabled, then the toolbar is at the top of the skin.'),
          toggle = function()
            COMPONENTS.SETTINGS:toggleLayoutToolbarAtTop()
            return true
          end,
          getState = function()
            return COMPONENTS.SETTINGS:getLayoutToolbarAtTop()
          end
        }),
        Settings.Boolean({
          title = LOCALIZATION:get('setting_slots_center_on_monitor_title', 'Center windows on the current monitor'),
          tooltip = LOCALIZATION:get('setting_slots_center_on_monitor_description', 'If enabled, then some windows (e.g. sort, filter) are centered on the monitor that the main window of this skin is on.'),
          toggle = function()
            COMPONENTS.SETTINGS:toggleCenterOnMonitor()
            return true
          end,
          getState = function()
            return COMPONENTS.SETTINGS:getCenterOnMonitor()
          end
        }),
        Settings.Boolean({
          title = LOCALIZATION:get('setting_skin_hide_skin_title', 'Hide skin while playing'),
          tooltip = LOCALIZATION:get('setting_skin_hide_skin_description', 'If enabled, then the skin is hidden while playing a game.'),
          toggle = function()
            COMPONENTS.SETTINGS:toggleHideSkin()
            return true
          end,
          getState = function()
            return COMPONENTS.SETTINGS:getHideSkin()
          end
        }),
        Settings.Boolean({
          title = LOCALIZATION:get('setting_bangs_enabled_title', 'Execute bangs'),
          tooltip = LOCALIZATION:get('setting_bangs_enabled_description', 'If enabled, then the specified Rainmeter bangs are executed when a game starts or terminates.'),
          toggle = function(self)
            COMPONENTS.SETTINGS:toggleBangsEnabled()
            return true
          end,
          getState = function(self)
            return COMPONENTS.SETTINGS:getBangsEnabled()
          end
        }),
        Settings.Action({
          title = LOCALIZATION:get('button_label_starting_bangs', 'Starting bangs'),
          tooltip = LOCALIZATION:get('setting_bangs_starting_description', 'These Rainmeter bangs are executed just before any game launches.'),
          label = LOCALIZATION:get('button_label_edit', 'Edit'),
          perform = function(self)
            local path = 'cache\\bangs.txt'
            local bangs = COMPONENTS.SETTINGS:getGlobalStartingBangs()
            io.writeFile(path, table.concat(bangs, '\n'))
            return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedGlobalStartingBangs')
          end
        }),
        Settings.Action({
          title = LOCALIZATION:get('button_label_stopping_bangs', 'Stopping bangs'),
          tooltip = LOCALIZATION:get('setting_bangs_stopping_description', 'These Rainmeter bangs are executed just after any game terminates.'),
          label = LOCALIZATION:get('button_label_edit', 'Edit'),
          perform = function(self)
            local path = 'cache\\bangs.txt'
            local bangs = COMPONENTS.SETTINGS:getGlobalStoppingBangs()
            io.writeFile(path, table.concat(bangs, '\n'))
            return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedGlobalStoppingBangs')
          end
        }),
        Settings.Spinner({
          title = LOCALIZATION:get('setting_localization_language_title', 'Language'),
          tooltip = LOCALIZATION:get('setting_localization_language_description', 'Select a language.'),
          index = getLanguageIndex(),
          setIndex = function(self, index)
            if index < 1 then
              index = #self:getValues()
            elseif index > #self:getValues() then
              index = 1
            end
            self.index = index
            local language = self:getValues()[self.index]
            return COMPONENTS.SETTINGS:setLocalization(language.displayValue)
          end,
          setValues = function(self)
            updateLanguages()
            return self:setIndex(getLanguageIndex())
          end,
          getValues = function(self)
            return state.languages
          end
        }),
        Settings.Integer({
          title = LOCALIZATION:get('setting_number_of_backups_title', 'Number of backups'),
          tooltip = LOCALIZATION:get('setting_number_of_backups_description', 'The number of daily backups to keep of the list of games.'),
          defaultValue = COMPONENTS.SETTINGS:getNumberOfBackups(),
          minValue = 0,
          maxValue = 100,
          onValueChanged = function(self, value)
            return COMPONENTS.SETTINGS:setNumberOfBackups(value)
          end
        }),
        Settings.Boolean({
          title = LOCALIZATION:get('setting_logging_title', 'Log'),
          tooltip = LOCALIZATION:get('setting_logging_description', 'If enabled, then a bunch of messages are printed to the Rainmeter log. Useful when troubleshooting issues.'),
          toggle = function(self)
            COMPONENTS.SETTINGS:toggleLogging()
            return true
          end,
          getState = function(self)
            return COMPONENTS.SETTINGS:getLogging()
          end
        })
      }
    end,
    __base = _base_0,
    __name = "Skin",
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
  Skin = _class_0
end
return Skin
