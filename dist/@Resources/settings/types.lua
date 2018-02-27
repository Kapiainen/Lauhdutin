local Base
do
  local _class_0
  local _base_0 = {
    getInc = function(self, index)
      return assert(nil, 'settings.types.Base.getInc')
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, args)
      assert(type(args) == 'table', 'settings.types.Base')
      assert(type(args.title) == 'string', 'settings.types.Base')
      assert(type(args.tooltip) == 'string', 'settings.types.Base')
      assert(type(args.type) == 'number' and args.type % 1 == 0, 'settings.types.Base')
      assert(args.type > 0 and args.type < ENUMS.SETTING_TYPES.MAX, 'settings.types.Base')
      self.title = args.title
      self.tooltip = args.tooltip
      self.type = args.type
    end,
    __base = _base_0,
    __name = "Base"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Base = _class_0
end
local Action
do
  local _class_0
  local _parent_0 = Base
  local _base_0 = {
    getInc = function(self, index)
      return table.concat({
        ('[Slot%dAction]'):format(index),
        'Text=UNDEFINED',
        'Meter=String',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dTitle:X] + [Slot%dTitle:W] / 2)'):format(index, index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        ('W=([Slot%dTitle:W])'):format(index),
        'H=#ButtonHeight#',
        'StringAlign=CenterCenter',
        'StringStyle=Bold',
        'FontSize=16',
        'AntiAlias=1',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dAction" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dAction" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dAction" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dAction" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "PerformAction(%d)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingAction'):format(index, index, index),
        '\n'
      }, '\n')
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, args)
      if args.type == nil then
        args.type = ENUMS.SETTING_TYPES.ACTION
      end
      _class_0.__parent.__init(self, args)
      self.label = args.label
      self.perform = args.perform
    end,
    __base = _base_0,
    __name = "Action",
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
  Action = _class_0
end
local Boolean
do
  local _class_0
  local _parent_0 = Base
  local _base_0 = {
    toggle = function(self)
      return self:toggleAction()
    end,
    getInc = function(self, index)
      return table.concat({
        ('[Slot%dBoolean]'):format(index),
        'Meter=Image',
        'ImageName=#@#settings\\gfx\\boolean_false.png',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dTitle:X])'):format(index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H] - #ButtonHeight#) / 2)'):format(index, index, index, index),
        'W=#ButtonHeight#',
        'H=#ButtonHeight#',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dBoolean" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dBoolean" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dBoolean" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dBoolean" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "ToggleBoolean(%d)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingBoolean'):format(index, index, index),
        '\n'
      }, '\n')
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, args)
      if args.type == nil then
        args.type = ENUMS.SETTING_TYPES.BOOLEAN
      end
      _class_0.__parent.__init(self, args)
      self.getState = args.getState
      self.toggle = args.toggle
    end,
    __base = _base_0,
    __name = "Boolean",
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
  Boolean = _class_0
end
local Integer
do
  local _class_0
  local _parent_0 = Base
  local _base_0 = {
    getValue = function(self)
      return self.value
    end,
    setValue = function(self, value)
      if self.minValue ~= nil and value < self.minValue then
        return 
      end
      if self.maxValue ~= nil and value > self.maxValue then
        return 
      end
      self.value = value
      return self:onValueChanged(self.value)
    end,
    incrementValue = function(self)
      if self.maxValue ~= nil and self.value + self.stepValue > self.maxValue then
        return 
      end
      self.value = self.value + self.stepValue
      return self:onValueChanged(self.value)
    end,
    decrementValue = function(self)
      if self.minValue ~= nil and self.value - self.stepValue < self.minValue then
        return 
      end
      self.value = self.value - self.stepValue
      return self:onValueChanged(self.value)
    end,
    onValueChanged = function(self, value) end,
    getInc = function(self, index)
      return table.concat({
        ('[Slot%dIntegerIncrement]'):format(index),
        'Meter=Image',
        'ImageName=#@#settings\\gfx\\integer_increment.png',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight#)'):format(index, index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H] - #ButtonHeight#) / 2)'):format(index, index, index, index),
        'W=#ButtonHeight#',
        'H=(#ButtonHeight# / 2)',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dIntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dIntegerIncrement" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dIntegerIncrement" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dIntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "IncrementInteger(%d)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingInteger'):format(index, index, index),
        '',
        ('[Slot%dIntegerDecrement]'):format(index),
        'Meter=Image',
        'ImageName=#@#settings\\gfx\\integer_decrement.png',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight#)'):format(index, index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        'W=#ButtonHeight#',
        'H=(#ButtonHeight# / 2)',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dIntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dIntegerDecrement" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dIntegerDecrement" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dIntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "DecrementInteger(%d)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingInteger'):format(index, index, index),
        '',
        ('[Slot%dIntegerValue]'):format(index),
        'Text=UNDEFINED',
        'Meter=String',
        'SolidColor=#SettingInputFieldBackgroundColor#',
        ('X=([Slot%dTitle:X])'):format(index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        ('W=([Slot%dTitle:W] - #ButtonHeight#)'):format(index, index),
        'H=#ButtonHeight#',
        'StringAlign=LeftCenter',
        'StringStyle=Bold',
        'FontSize=16',
        'AntiAlias=1',
        'DynamicVariables=1',
        ('LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingIntegerPath(%d)"]'):format(index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingInteger'):format(index, index, index),
        '\n'
      }, '\n')
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, args)
      if args.type == nil then
        args.type = ENUMS.SETTING_TYPES.INTEGER
      end
      _class_0.__parent.__init(self, args)
      self.value = args.defaultValue or 0
      self.minValue = args.minValue or nil
      self.maxValue = args.maxValue or nil
      self.stepValue = args.stepValue or 1
      if args.getValue ~= nil then
        self.getValue = args.getValue
      end
      if args.setValue ~= nil then
        self.setValue = args.setValue
      end
      if args.onValueChanged ~= nil then
        self.onValueChanged = args.onValueChanged
      end
    end,
    __base = _base_0,
    __name = "Integer",
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
  Integer = _class_0
end
local FolderPath
do
  local _class_0
  local _parent_0 = Base
  local _base_0 = {
    startBrowsing = function(self)
      return ('""cscript \"#@#settings\\folderBrowser.vbs\" \"%s\"""'):format(self.dialogTitle)
    end,
    getInc = function(self, index)
      return table.concat({
        ('[Slot%dFolderPathBrowse]'):format(index),
        'Text=Browse',
        'Meter=String',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dBoundingBox:X] + [Slot%dBoundingBox:W] - #ButtonHeight# - 4)'):format(index, index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        'W=(2 * #ButtonHeight#)',
        'H=#ButtonHeight#',
        'StringAlign=CenterCenter',
        'StringStyle=Bold',
        'FontSize=16',
        'AntiAlias=1',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dFolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dFolderPathBrowse" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dFolderPathBrowse" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dFolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPath(%d)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPath'):format(index, index, index),
        '',
        ('[Slot%dFolderPathValue]'):format(index),
        'Text=UNDEFINED',
        'Meter=String',
        'SolidColor=#SettingInputFieldBackgroundColor#',
        ('X=([Slot%dTitle:X])'):format(index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        ('W=([Slot%dTitle:W] - [Slot%dFolderPathBrowse:W])'):format(index, index),
        'H=#ButtonHeight#',
        'StringAlign=LeftCenter',
        'StringStyle=Bold',
        'FontSize=16',
        'AntiAlias=1',
        'DynamicVariables=1',
        ('LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPath(%d)"]'):format(index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPath'):format(index, index, index),
        '\n'
      }, '\n')
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, args)
      if args.type == nil then
        args.type = ENUMS.SETTING_TYPES.FOLDER_PATH
      end
      _class_0.__parent.__init(self, args)
      self.getValue = args.getValue
      self.setValue = args.setValue
      self.dialogTitle = args.dialogTitle or 'Select a folder'
    end,
    __base = _base_0,
    __name = "FolderPath",
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
  FolderPath = _class_0
end
local Spinner
do
  local _class_0
  local _parent_0 = Base
  local _base_0 = {
    getIndex = function(self)
      return self.index
    end,
    setIndex = function(self, index)
      if index < 1 then
        index = #self:getValues()
      elseif index > #self:getValues() then
        index = 1
      end
      self.index = index
    end,
    getValues = function(self)
      return self.values
    end,
    setValues = function(self, values)
      self.values = values
      return self:setIndex(1)
    end,
    getInc = function(self, index)
      return table.concat({
        ('[Slot%dSpinnerUp]'):format(index),
        'Meter=Image',
        'ImageName=#@#settings\\gfx\\spinner_up.png',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight#)'):format(index, index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H] - #ButtonHeight#) / 2)'):format(index, index, index, index),
        'W=#ButtonHeight#',
        'H=(#ButtonHeight# / 2)',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dSpinnerUp" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dSpinnerUp" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(%d, -1)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingSpinner'):format(index, index, index),
        '',
        ('[Slot%dSpinnerDown]'):format(index),
        'Meter=Image',
        'ImageName=#@#settings\\gfx\\spinner_down.png',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight#)'):format(index, index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        'W=#ButtonHeight#',
        'H=(#ButtonHeight# / 2)',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dSpinnerDown" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dSpinnerDown" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(%d, 1)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingSpinner'):format(index, index, index),
        '',
        ('[Slot%dSpinnerValue]'):format(index),
        'Text=UNDEFINED',
        'Meter=String',
        'SolidColor=#SettingInputFieldBackgroundColor#',
        ('X=([Slot%dTitle:X])'):format(index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        ('W=([Slot%dTitle:W] - #ButtonHeight#)'):format(index, index),
        'H=#ButtonHeight#',
        'StringAlign=LeftCenter',
        'StringStyle=Bold',
        'FontSize=16',
        'AntiAlias=1',
        'DynamicVariables=1',
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingSpinner'):format(index, index, index),
        '\n'
      }, '\n')
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, args)
      if args.type == nil then
        args.type = ENUMS.SETTING_TYPES.SPINNER
      end
      _class_0.__parent.__init(self, args)
      self.index = args.index
      self.values = {
        'UNDEFINED'
      }
      if args.getIndex ~= nil then
        self.getIndex = args.getIndex
      end
      if args.setIndex ~= nil then
        self.setIndex = args.setIndex
      end
      if args.getValues ~= nil then
        self.getValues = args.getValues
      end
      if args.setValues ~= nil then
        self.setValues = args.setValues
      end
    end,
    __base = _base_0,
    __name = "Spinner",
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
  Spinner = _class_0
end
local FolderPathSpinner
do
  local _class_0
  local _parent_0 = Spinner
  local _base_0 = {
    startBrowsing = function(self)
      return ('""cscript \"#@#settings\\folderBrowser.vbs\" \"%s\"""'):format(self.dialogTitle)
    end,
    getIndex = function(self)
      return self.index
    end,
    setIndex = function(self, index)
      if index < 1 then
        index = #self:getValues()
      elseif index > #self:getValues() then
        index = 1
      end
      self.index = index
    end,
    getValues = function(self)
      return self.values
    end,
    setValues = function(self, values)
      self.values = values
      return self:setIndex(1)
    end,
    setPath = function(self, index, path)
      self.values[index] = path
    end,
    getInc = function(self, index)
      return table.concat({
        ('[Slot%dFolderPathSpinnerBrowse]'):format(index),
        'Text=Browse',
        'Meter=String',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dBoundingBox:X] + [Slot%dBoundingBox:W] - #ButtonHeight# - 4)'):format(index, index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        'W=(2 * #ButtonHeight#)',
        'H=#ButtonHeight#',
        'StringAlign=CenterCenter',
        'StringStyle=Bold',
        'FontSize=16',
        'AntiAlias=1',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dFolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dFolderPathSpinnerBrowse" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dFolderPathSpinnerBrowse" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dFolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPathSpinner(%d)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPathSpinner'):format(index, index, index),
        '',
        ('[Slot%dFolderPathSpinnerUp]'):format(index),
        'Meter=Image',
        'ImageName=#@#settings\\gfx\\spinner_up.png',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight# - [Slot%dFolderPathSpinnerBrowse:W])'):format(index, index, index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H] - #ButtonHeight#) / 2)'):format(index, index, index, index),
        'W=#ButtonHeight#',
        'H=(#ButtonHeight# / 2)',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dFolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dFolderPathSpinnerUp" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dFolderPathSpinnerUp" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dFolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(%d, -1)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPathSpinner'):format(index, index, index),
        '',
        ('[Slot%dFolderPathSpinnerDown]'):format(index),
        'Meter=Image',
        'ImageName=#@#settings\\gfx\\spinner_down.png',
        'SolidColor=#ButtonBaseColor#',
        ('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight# - [Slot%dFolderPathSpinnerBrowse:W])'):format(index, index, index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        'W=#ButtonHeight#',
        'H=(#ButtonHeight# / 2)',
        'DynamicVariables=1',
        ('MouseOverAction=[!SetOption "Slot%dFolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]'):format(index),
        ('MouseLeaveAction=[!SetOption "Slot%dFolderPathSpinnerDown" "SolidColor" "#ButtonBaseColor#"]'):format(index),
        ('LeftMouseDownAction=[!SetOption "Slot%dFolderPathSpinnerDown" "SolidColor" "#ButtonPressedColor#"]'):format(index),
        ('LeftMouseUpAction=[!SetOption "Slot%dFolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(%d, 1)"]'):format(index, index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPathSpinner'):format(index, index, index),
        '',
        ('[Slot%dFolderPathSpinnerValue]'):format(index),
        'Text=UNDEFINED',
        'Meter=String',
        'SolidColor=#SettingInputFieldBackgroundColor#',
        ('X=([Slot%dTitle:X])'):format(index),
        ('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)'):format(index, index, index, index),
        ('W=([Slot%dTitle:W] - #ButtonHeight# - [Slot%dFolderPathSpinnerBrowse:W])'):format(index, index, index),
        'H=#ButtonHeight#',
        'StringAlign=LeftCenter',
        'StringStyle=Bold',
        'FontSize=16',
        'AntiAlias=1',
        'DynamicVariables=1',
        ('LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPathSpinner(%d)"]'):format(index),
        ('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPathSpinner'):format(index, index, index),
        '\n'
      }, '\n')
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, args)
      if args.type == nil then
        args.type = ENUMS.SETTING_TYPES.FOLDER_PATH_SPINNER
      end
      _class_0.__parent.__init(self, args)
      if args.setPath ~= nil then
        self.setPath = args.setPath
      end
      self.dialogTitle = args.dialogTitle or 'Select a folder'
    end,
    __base = _base_0,
    __name = "FolderPathSpinner",
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
  FolderPathSpinner = _class_0
end
return {
  Action = Action,
  Boolean = Boolean,
  Integer = Integer,
  FolderPath = FolderPath,
  Spinner = Spinner,
  FolderPathSpinner = FolderPathSpinner
}
