local Animation = require('main.animations.animation')
local zoomInFrame
zoomInFrame = function(x, y, w, h, scale)
  return {
    ('[!SetOption "SlotAnimation" "X" "%d"]'):format(x - w * (scale - 1) / 2),
    ('[!SetOption "SlotAnimation" "Y" "%d"]'):format(y - h * (scale - 1) / 2),
    ('[!SetOption "SlotAnimation" "W" "%d"]'):format(w * scale),
    ('[!SetOption "SlotAnimation" "H" "%d"]'):format(h * scale),
    '[!UpdateMeter "SlotAnimation"]'
  }
end
local jiggleFrame
jiggleFrame = function(mag)
  return {
    ('[!SetOption "SlotAnimation" "ImageRotate" "%d"]'):format(mag),
    '[!UpdateMeter "SlotAnimation"]'
  }
end
local shakeFrame
shakeFrame = function(option, pos, mag)
  return {
    ('[!SetOption "SlotAnimation" "%s" "%d"]'):format(option, pos - mag),
    '[!UpdateMeter "SlotAnimation"]'
  }
end
local SlotHoverAnimation
do
  local _class_0
  local _parent_0 = Animation
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, index, typ, banner)
      assert(type(index) == 'number' and index % 1 == 0, 'main.animations.slot_hover_animation.SlotHoverAnimation')
      assert(type(typ) == 'number' and typ % 1 == 0, 'main.animations.slot_hover_animation.SlotHoverAnimation')
      assert(type(banner) == 'string', 'main.animations.slot_hover_animation.SlotHoverAnimation')
      local resetAction
      resetAction = function(self)
        SKIN:Bang('[!SetOption "SlotsBackgroundCutout" "Shape2" "Rectangle 0,0,0,0 | StrokeWidth 0"]')
        return SKIN:Bang(('[!UpdateMeter "SlotsBackgroundCutout"][!ShowMeter "Slot%dImage"]'):format(index))
      end
      local frames = { }
      local slot = SKIN:GetMeter(('Slot%dImage'):format(index))
      local slotX = slot:GetX()
      local slotY = slot:GetY()
      local slotW = slot:GetW()
      local slotH = slot:GetH()
      frames[1] = {
        '[!ShowMeterGroup "Slots"]',
        ('[!SetOption "SlotAnimation" "ImageName" "#@#%s"]'):format(banner),
        ('[!SetOption "SlotAnimation" "X" "%d"]'):format(slotX),
        ('[!SetOption "SlotAnimation" "Y" "%d"]'):format(slotY),
        ('[!SetOption "SlotAnimation" "W" "%d"]'):format(slotW),
        ('[!SetOption "SlotAnimation" "H" "%d"]'):format(slotH),
        ('[!SetOption "SlotsBackgroundCutout" "Shape2" "Rectangle %d,%d,%d,%d | StrokeWidth 0"]'):format(slotX, slotY, slotW, slotH),
        '[!UpdateMeter "SlotAnimation"][!UpdateMeter "SlotsBackgroundCutout"]',
        ('[!HideMeter "Slot%dImage"][!UpdateMeter "Slot%dImage"]'):format(index, index)
      }
      local _exp_0 = typ
      if ENUMS.SLOT_HOVER_ANIMATIONS.ZOOM_IN == _exp_0 then
        resetAction = nil
        frames[2] = zoomInFrame(slotX, slotY, slotW, slotH, 1.05)
        frames[3] = zoomInFrame(slotX, slotY, slotW, slotH, 1.10)
        frames[4] = zoomInFrame(slotX, slotY, slotW, slotH, 1.15)
      elseif ENUMS.SLOT_HOVER_ANIMATIONS.JIGGLE == _exp_0 then
        frames[2] = jiggleFrame(2)
        frames[3] = jiggleFrame(0)
        frames[4] = jiggleFrame(-2)
        frames[5] = jiggleFrame(0)
      elseif ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_LEFT_RIGHT == _exp_0 then
        frames[2] = shakeFrame('X', slotX, -5)
        frames[3] = shakeFrame('X', slotX, 0)
        frames[4] = shakeFrame('X', slotX, 5)
        frames[5] = shakeFrame('X', slotX, 0)
      elseif ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_UP_DOWN == _exp_0 then
        frames[2] = shakeFrame('Y', slotY, -5)
        frames[3] = shakeFrame('Y', slotY, 0)
        frames[4] = shakeFrame('Y', slotY, 5)
        frames[5] = shakeFrame('Y', slotY, 0)
      else
        assert(nil, 'main.animations.slot_hover_animation.SlotHoverAnimation')
      end
      local args = {
        resetAction = resetAction,
        frames = frames,
        mandatory = false,
        finishAction = nil
      }
      return _class_0.__parent.__init(self, args)
    end,
    __base = _base_0,
    __name = "SlotHoverAnimation",
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
  SlotHoverAnimation = _class_0
end
return SlotHoverAnimation
