local build
build = function(settings)
  local slotsWide = settings:getLayoutColumns()
  local slotsTall = settings:getLayoutRows()
  local numSlots = slotsWide * slotsTall
  local slotWidth = settings:getLayoutWidth()
  local slotHeight = settings:getLayoutHeight()
  local horizontal = settings:getLayoutHorizontal()
  local skinWidth = slotsWide * slotWidth
  local skinHeight = slotsTall * slotHeight
  local contents = table.concat({
    '[Variables]',
    ('SkinWidth=%d'):format(skinWidth),
    ('SkinHeight=%d'):format(skinHeight),
    ('SlotWidth=%d'):format(slotWidth),
    ('SlotHeight=%d'):format(slotHeight),
    ('SlotOverlayTextSize=%d'):format(math.round(12 * slotWidth / 320)),
    '\n'
  }, '\n')
  local skinSlideAnimation = settings:getSkinSlideAnimation()
  if skinSlideAnimation ~= ENUMS.SKIN_ANIMATIONS.NONE then
    local enablerX
    local _exp_0 = skinSlideAnimation
    if ENUMS.SKIN_ANIMATIONS.SLIDE_UP == _exp_0 then
      enablerX = 0
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT == _exp_0 then
      enablerX = skinWidth - 1
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN == _exp_0 then
      enablerX = 0
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT == _exp_0 then
      enablerX = 0
    else
      enablerX = assert(nil, 'settings.build_main_skin.build')
    end
    local enablerY
    local _exp_1 = skinSlideAnimation
    if ENUMS.SKIN_ANIMATIONS.SLIDE_UP == _exp_1 then
      enablerY = 0
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT == _exp_1 then
      enablerY = 0
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN == _exp_1 then
      enablerY = skinHeight - 1
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT == _exp_1 then
      enablerY = 0
    else
      enablerY = assert(nil, 'settings.build_main_skin.build')
    end
    local enablerWidth
    local _exp_2 = skinSlideAnimation
    if ENUMS.SKIN_ANIMATIONS.SLIDE_UP == _exp_2 then
      enablerWidth = skinWidth
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT == _exp_2 then
      enablerWidth = 1
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN == _exp_2 then
      enablerWidth = skinWidth
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT == _exp_2 then
      enablerWidth = 1
    else
      enablerWidth = assert(nil, 'settings.build_main_skin.build')
    end
    local enablerHeight
    local _exp_3 = skinSlideAnimation
    if ENUMS.SKIN_ANIMATIONS.SLIDE_UP == _exp_3 then
      enablerHeight = 1
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT == _exp_3 then
      enablerHeight = skinHeight
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN == _exp_3 then
      enablerHeight = 1
    elseif ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT == _exp_3 then
      enablerHeight = skinHeight
    else
      enablerHeight = assert(nil, 'settings.build_main_skin.build')
    end
    contents = contents .. table.concat({
      '[SkinEnabler]',
      'Meter=Image',
      'SolidColor=0,0,0,1',
      ('X=%d'):format(enablerX),
      ('Y=%d'):format(enablerY),
      ('W=%d'):format(enablerWidth),
      ('H=%d'):format(enablerHeight),
      'MouseOverAction=[!CommandMeasure "Script" "OnMouseOver()"]',
      'MouseLeaveAction=[!CommandMeasure "Script" "OnMouseLeaveEnabler()"]',
      '\n'
    }, '\n')
  end
  contents = contents .. table.concat({
    '[SlotsBackground]',
    'Meter=Image',
    'SolidColor=#SlotBackgroundColor#',
    'X=0',
    'Y=0',
    'W=#SkinWidth#',
    'H=#SkinHeight#',
    'MouseScrollUpAction=[!CommandMeasure "Script" "OnScrollSlots(-1)"]',
    'MouseScrollDownAction=[!CommandMeasure "Script" "OnScrollSlots(1)"]',
    'MouseOverAction=[!CommandMeasure "Script" "OnMouseOver()"]',
    '\n'
  }, '\n')
  contents = contents .. table.concat({
    '[SlotAnimation]',
    'Meter=Image',
    'ImageName=',
    'SolidColor=0,0,0,1',
    'X=0',
    'Y=0',
    'W=0',
    'H=0',
    'PreserveAspectRatio=2',
    '\n'
  }, '\n')
  contents = contents .. table.concat({
    '[SlotsBackgroundCutout]',
    'Meter=Shape',
    'X=([SlotsBackground:X])',
    'Y=([SlotsBackground:Y])',
    'Shape=Rectangle 0,0,#SkinWidth#,#SkinHeight# | Fill Color #SlotBackgroundColor# | StrokeWidth 0',
    'Shape2=Rectangle 0,0,0,0 | StrokeWidth 0',
    'Shape3=Combine Shape | XOR Shape2',
    'DynamicVariables=1',
    '\n'
  }, '\n')
  local index = 1
  local leftMouseAction
  local _exp_0 = settings:getDoubleClickToLaunch()
  if true == _exp_0 then
    leftMouseAction = 'LeftMouseDoubleClickAction'
  else
    leftMouseAction = 'LeftMouseUpAction'
  end
  local gameSlot
  gameSlot = function(row, column)
    local slot = { }
    table.extend(slot, {
      ('[Slot%dText]'):format(index),
      'Meter=String',
      'Text=',
      'SolidColor=0,0,0,1',
      ('X=([SlotsBackground:X] + %d)'):format((column - 1) * slotWidth + math.floor(slotWidth / 2)),
      ('Y=([SlotsBackground:Y] + %d)'):format((row - 1) * slotHeight + math.floor(slotHeight / 2)),
      ('W=%d'):format(slotWidth),
      ('H=%d'):format(slotHeight),
      'FontSize=#SlotOverlayTextSize#',
      'FontColor=#SlotOverlayTextColor#',
      'StringAlign=CenterCenter',
      'StringEffect=Shadow',
      'StringStyle=Bold',
      'AntiAlias=1',
      'ClipString=1',
      'DynamicVariables=1',
      ('%s=[!CommandMeasure "Script" "OnLeftClickSlot(%d)"]'):format(leftMouseAction, index),
      ('MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(%d)"]'):format(index),
      ('MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(%d)"]'):format(index),
      ('MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(%d)"]'):format(index),
      ('Group=Slots|Slot%d'):format(index)
    })
    table.insert(slot, '')
    table.extend(slot, {
      ('[Slot%dImage]'):format(index),
      'Meter=Image',
      'ImageName=',
      'SolidColor=0,0,0,1',
      ('X=([SlotsBackground:X] + %d)'):format((column - 1) * slotWidth),
      ('Y=([SlotsBackground:Y] + %d)'):format((row - 1) * slotHeight),
      ('W=%d'):format(slotWidth),
      ('H=%d'):format(slotHeight),
      'PreserveAspectRatio=2',
      'DynamicVariables=1',
      ('Group=Slots|Slot%d'):format(index)
    })
    table.insert(slot, '\n')
    return slot
  end
  if horizontal then
    for row = 1, slotsTall do
      for column = 1, slotsWide do
        contents = contents .. table.concat(gameSlot(row, column), '\n')
        index = index + 1
      end
    end
  else
    for column = 1, slotsWide do
      for row = 1, slotsTall do
        contents = contents .. table.concat(gameSlot(row, column), '\n')
        index = index + 1
      end
    end
  end
  local overlay = { }
  table.extend(overlay, {
    '[SlotOverlayImage]',
    'Meter=Image',
    'ImageName=',
    'SolidColor=#SlotOverlayColor#',
    'X=0',
    'Y=0',
    ('W=%d'):format(slotWidth),
    ('H=%d'):format(slotHeight),
    'PreserveAspectRatio=2',
    'Group=SlotOverlay'
  })
  table.insert(overlay, '')
  table.extend(overlay, {
    '[SlotOverlayText]',
    'Meter=String',
    'Text=',
    ('X=%dr'):format(math.floor(slotWidth / 2)),
    ('Y=%dr'):format(math.floor(slotHeight / 2)),
    ('W=%d'):format(slotWidth),
    ('H=%d'):format(slotHeight),
    'FontSize=#SlotOverlayTextSize#',
    'FontColor=#SlotOverlayTextColor#',
    'StringAlign=CenterCenter',
    'StringEffect=Shadow',
    'StringStyle=Bold',
    'AntiAlias=1',
    'ClipString=1',
    'Group=SlotOverlay'
  })
  table.insert(overlay, '')
  contents = contents .. table.concat(overlay, '\n')
  return contents
end
return build
