local Slot
do
  local _class_0
  local _base_0 = {
    update = function(self, setting)
      if setting == nil then
        return SKIN:Bang(('[!HideMeterGroup "Slot%d"]'):format(self.index))
      end
      SKIN:Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]'):format(self.index, setting.title))
      SKIN:Bang(('[!SetOption "Slot%dToolTip" "ToolTipText" "%s"]'):format(self.index, setting.tooltip))
      SKIN:Bang(('[!ShowMeterGroup "Slot%d"]'):format(self.index))
      SKIN:Bang(('[!HideMeterGroup "Slot%dSettings"]'):format(self.index))
      local _exp_0 = setting.type
      if ENUMS.SETTING_TYPES.ACTION == _exp_0 then
        SKIN:Bang(('[!SetOption "Slot%dAction" "Text" "%s"]'):format(self.index, setting.label))
        return SKIN:Bang(('[!ShowMeterGroup "Slot%dSettingAction"]'):format(self.index))
      elseif ENUMS.SETTING_TYPES.BOOLEAN == _exp_0 then
        if setting:getState() then
          SKIN:Bang(('[!SetOption "Slot%dBoolean" "ImageName" "#@#settings\\gfx\\boolean_true.png"]'):format(self.index))
        else
          SKIN:Bang(('[!SetOption "Slot%dBoolean" "ImageName" "#@#settings\\gfx\\boolean_false.png"]'):format(self.index))
        end
        return SKIN:Bang(('[!ShowMeterGroup "Slot%dSettingBoolean"]'):format(self.index))
      elseif ENUMS.SETTING_TYPES.FOLDER_PATH == _exp_0 then
        SKIN:Bang(('[!SetOption "Slot%dFolderPathValue" "Text" "%s"]'):format(self.index, setting:getValue()))
        SKIN:Bang(('[!SetOption "Slot%dFolderPathBrowse" "Text" "%s"]'):format(self.index, LOCALIZATION:get('button_label_browse', 'Browse')))
        return SKIN:Bang(('[!ShowMeterGroup "Slot%dSettingFolderPath"]'):format(self.index))
      elseif ENUMS.SETTING_TYPES.SPINNER == _exp_0 then
        SKIN:Bang(('[!SetOption "Slot%dSpinnerValue" "Text" "%s"]'):format(self.index, setting:getValues()[setting:getIndex()].displayValue))
        return SKIN:Bang(('[!ShowMeterGroup "Slot%dSettingSpinner"]'):format(self.index))
      elseif ENUMS.SETTING_TYPES.INTEGER == _exp_0 then
        SKIN:Bang(('[!SetOption "Slot%dIntegerValue" "Text" "%d"]'):format(self.index, setting:getValue()))
        return SKIN:Bang(('[!ShowMeterGroup "Slot%dSettingInteger"]'):format(self.index))
      elseif ENUMS.SETTING_TYPES.FOLDER_PATH_SPINNER == _exp_0 then
        SKIN:Bang(('[!SetOption "Slot%dFolderPathSpinnerValue" "Text" "%s"]'):format(self.index, setting:getValues()[setting:getIndex()]))
        SKIN:Bang(('[!SetOption "Slot%dFolderPathSpinnerBrowse" "Text" "%s"]'):format(self.index, LOCALIZATION:get('button_label_browse', 'Browse')))
        return SKIN:Bang(('[!ShowMeterGroup "Slot%dSettingFolderPathSpinner"]'):format(self.index))
      else
        return assert(nil, 'settings.slots.slot.Slot.update')
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, index)
      assert(type(index) == 'number' and index % 1 == 0, 'settings.slots.slot.Slot')
      self.index = index
    end,
    __base = _base_0,
    __name = "Slot"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Slot = _class_0
end
return Slot
