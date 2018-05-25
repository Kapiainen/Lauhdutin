local build
build = function()
  local contents = '[SlotBackground]\nMeter=Image\nSolidColor=0,0,0,1\nX=([WindowBackground:X] + 2)\nY=([WindowBackground:Y] + #TitleBarHeight#)\nW=([WindowBackground:W] - 3)\nH=([WindowBackground:H] - #TitleBarHeight# - #ButtonHeight#)\nMouseScrollUpAction=[!CommandMeasure "Script" "ScrollSlots(-1)"]\nMouseScrollDownAction=[!CommandMeasure "Script" "ScrollSlots(1)"]\nDynamicVariables=1\n'
  contents = contents .. '\n[ScrollBarBackground]\nMeter=Image\nSolidColor=#ScrollbarBackgroundColor#\nX=([WindowBackground:X] + [WindowBackground:W] - #ScrollBarWidth#)\nY=([SlotBackground:Y])\nW=#ScrollBarWidth#\nH=([SlotBackground:H])\nDynamicVariables=1\n\n[ScrollBar]\nMeter=Image\nSolidColor=#ScrollbarColor#\nX=([ScrollBarBackground:X] + 1)\nY=([ScrollBarBackground:Y] + 1)\nW=([ScrollBarBackground:W] - 1)\nH=([ScrollBarBackground:H] - 2)\nDynamicVariables=1\n'
  contents = contents .. '\n[FolderPathInput]\nMeasure=Plugin\nPlugin=InputText\nSolidColor=#WindowBackgroundColor#\nX=0\nY=0\nW=0\nH=0\nDefaultValue=\nStringAlign=Left\nStringStyle=Bold\nFontSize=16\nDynamicVariables=1'
  for i = 1, STATE.NUM_SLOTS do
    contents = contents .. ('Command%d=[!CommandMeasure "Script" "EditFolderPath(%d, \'$UserInput$;\')"]\n'):format(i, i)
  end
  contents = contents .. '\n'
  contents = contents .. '\n[FolderPathSpinnerInput]\nMeasure=Plugin\nPlugin=InputText\nSolidColor=#WindowBackgroundColor#\nX=0\nY=0\nW=0\nH=0\nDefaultValue=\nStringAlign=Left\nStringStyle=Bold\nFontSize=16\nDynamicVariables=1'
  for i = 1, STATE.NUM_SLOTS do
    contents = contents .. ('Command%d=[!CommandMeasure "Script" "EditFolderPathSpinner(%d, \'$UserInput$;\')"]\n'):format(i, i)
  end
  contents = contents .. '\n'
  contents = contents .. '\n[IntegerInput]\nMeasure=Plugin\nPlugin=InputText\nSolidColor=#WindowBackgroundColor#\nX=0\nY=0\nW=0\nH=0\nDefaultValue=\nInputNumber=1\nStringAlign=Left\nStringStyle=Bold\nFontSize=16\nDynamicVariables=1\n'
  for i = 1, STATE.NUM_SLOTS do
    contents = contents .. ('Command%d=[!CommandMeasure "Script" "EditInteger(%d, \'$UserInput$\')"]\n'):format(i, i)
  end
  contents = contents .. '\n'
  local Settings = require('settings.types')
  local args = {
    title = '',
    tooltip = ''
  }
  local settings
  do
    local _accum_0 = { }
    local _len_0 = 1
    for key, Setting in pairs(Settings) do
      _accum_0[_len_0] = Setting(args)
      _len_0 = _len_0 + 1
    end
    settings = _accum_0
  end
  for i = 1, STATE.NUM_SLOTS do
    contents = contents .. table.concat({
      ('[Slot%dBoundingBox]'):format(i),
      'Meter=Image',
      'SolidColor=0,0,0,1',
      'X=([SlotBackground:X])',
      ('Y=([SlotBackground:Y] + %d * [SlotBackground:H] / %d)'):format(i - 1, STATE.NUM_SLOTS),
      'W=([SlotBackground:W] - #ScrollBarWidth# - 2)',
      ('H=([SlotBackground:H] / %d)'):format(STATE.NUM_SLOTS),
      'DynamicVariables=1',
      ('Group=Slot%d'):format(i),
      '',
      ('[Slot%dToolTip]'):format(i),
      'Meter=Image',
      'ImageName=#@#settings\\gfx\\tooltip.png',
      'SolidColor=0,0,0,1',
      ('X=([Slot%dBoundingBox:X] + 2)'):format(i),
      ('Y=([Slot%dBoundingBox:Y] + 8)'):format(i),
      'W=16',
      'H=16',
      ('ToolTipText=Slot %d'):format(i),
      ('Group=Slot%d'):format(i),
      '',
      ('[Slot%dTitle]'):format(i),
      'Meter=String',
      ('Text=Slot %d'):format(i),
      'StringAlign=LeftCenter',
      'SolidColor=0,0,0,1',
      'X=2R',
      'Y=8r',
      'FontSize=16',
      'AntiAlias=1',
      'StringStyle=Bold',
      ('W=([Slot%dBoundingBox:W] - 24)'):format(i),
      'H=32',
      'ClipString=1',
      'DynamicVariables=1',
      ('Group=Slot%d'):format(i),
      '\n'
    }, '\n')
    for _index_0 = 1, #settings do
      local setting = settings[_index_0]
      contents = contents .. setting:getInc(i)
    end
    if i < STATE.NUM_SLOTS then
      i = i + 1
      contents = contents .. table.concat({
        ('[Slot%dSeparator]'):format(i),
        'Meter=Image',
        'SolidColor=#SlotSeparatorColor#',
        'X=([WindowBackground:X] + 2)',
        ('Y=([Slot%dBoundingBox:Y] + [Slot%dBoundingBox:H] - 1)'):format(i - 1, i - 1),
        ('W=([Slot%dBoundingBox:W])'):format(i - 1),
        'H=2',
        'DynamicVariables=1',
        ('Group=Slot%d'):format(i),
        '\n'
      }, '\n')
    end
  end
  return contents
end
return build
