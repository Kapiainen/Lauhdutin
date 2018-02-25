local Animation = require('main.animations.animation')
local slideFrame
slideFrame = function(option, pos, dim, scale)
  return {
    ('[!SetOption "SlotAnimation" "%s" "%d"]'):format(option, pos + dim * scale),
    '[!UpdateMeter "SlotAnimation"]'
  }
end
local shrinkFrame
shrinkFrame = function(x, y, w, h, scale)
  return {
    ('[!SetOption "SlotAnimation" "X" "%d"]'):format(x + (w - w * scale) / 2),
    ('[!SetOption "SlotAnimation" "Y" "%d"]'):format(y + (h - h * scale) / 2),
    ('[!SetOption "SlotAnimation" "W" "%d"]'):format(w * scale),
    ('[!SetOption "SlotAnimation" "H" "%d"]'):format(h * scale),
    '[!UpdateMeter "SlotAnimation"]'
  }
end
local SlotClickAnimation
do
  local _class_0
  local _parent_0 = Animation
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, index, typ, action, game, banner)
      assert(type(index) == 'number' and index % 1 == 0, 'main.animations.slot_click_animation.SlotClickAnimation')
      assert(type(typ) == 'number' and typ % 1 == 0, 'main.animations.slot_click_animation.SlotClickAnimation')
      assert(type(action) == 'function', 'main.animations.slot_click_animation.SlotClickAnimation')
      assert(type(game) == 'table', 'main.animations.slot_click_animation.SlotClickAnimation')
      assert(type(banner) == 'string', 'main.animations.slot_click_animation.SlotClickAnimation')
      local resetAction
      resetAction = function(self)
        SKIN:Bang('[!SetOption "SlotsBackgroundCutout" "Shape2" "Rectangle 0,0,0,0 | StrokeWidth 0"]')
        return SKIN:Bang(('[!UpdateMeter "SlotsBackgroundCutout"][!ShowMeter "Slot%dImage"]'):format(index))
      end
      local finishAction
      finishAction = function(self)
        return action(game)
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
      if ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_UP == _exp_0 then
        frames[2] = slideFrame('Y', slotY, -slotH, 1 / 1.8)
        frames[3] = slideFrame('Y', slotY, -slotH, 1 / 2.5)
        frames[4] = slideFrame('Y', slotY, -slotH, 1 / 4.0)
        frames[5] = slideFrame('Y', slotY, -slotH, 1 / 12.0)
        frames[6] = slideFrame('Y', slotY, -slotH, 1 / 20.0)
      elseif ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_RIGHT == _exp_0 then
        frames[2] = slideFrame('X', slotX, slotW, 1 / 1.8)
        frames[3] = slideFrame('X', slotX, slotW, 1 / 2.5)
        frames[4] = slideFrame('X', slotX, slotW, 1 / 4.0)
        frames[5] = slideFrame('X', slotX, slotW, 1 / 12.0)
        frames[6] = slideFrame('X', slotX, slotW, 1 / 20.0)
      elseif ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_DOWN == _exp_0 then
        frames[2] = slideFrame('Y', slotY, slotH, 1 / 1.8)
        frames[3] = slideFrame('Y', slotY, slotH, 1 / 2.5)
        frames[4] = slideFrame('Y', slotY, slotH, 1 / 4.0)
        frames[5] = slideFrame('Y', slotY, slotH, 1 / 12.0)
        frames[6] = slideFrame('Y', slotY, slotH, 1 / 20.0)
      elseif ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_LEFT == _exp_0 then
        frames[2] = slideFrame('X', slotX, -slotW, 1 / 1.8)
        frames[3] = slideFrame('X', slotX, -slotW, 1 / 2.5)
        frames[4] = slideFrame('X', slotX, -slotW, 1 / 4.0)
        frames[5] = slideFrame('X', slotX, -slotW, 1 / 12.0)
        frames[6] = slideFrame('X', slotX, -slotW, 1 / 20.0)
      elseif ENUMS.SLOT_CLICK_ANIMATIONS.SHRINK == _exp_0 then
        frames[2] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 1.8)
        frames[3] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 2.5)
        frames[4] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 4.0)
        frames[5] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 12.0)
        frames[6] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 20.0)
      else
        assert(nil, 'main.animations.slot_click_animation.SlotClickAnimation')
      end
      local args = {
        resetAction = resetAction,
        finishAction = finishAction,
        frames = frames,
        mandatory = true
      }
      return _class_0.__parent.__init(self, args)
    end,
    __base = _base_0,
    __name = "SlotClickAnimation",
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
  SlotClickAnimation = _class_0
end
return SlotClickAnimation
