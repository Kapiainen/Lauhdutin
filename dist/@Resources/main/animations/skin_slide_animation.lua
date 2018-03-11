local Animation = require('main.animations.animation')
local slideFrame
slideFrame = function(option, pos, mag, scale)
  return {
    ('[!SetOption "SlotsBackground" "%s" "%d"]'):format(option, pos + mag * scale),
    '[!UpdateMeter "SlotsBackground"][!UpdateMeter "SlotsBackgroundCutout"][!UpdateMeterGroup "Slots"]'
  }
end
local SkinSlideAnimation
do
  local _class_0
  local _parent_0 = Animation
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, typ, reveal)
      assert(type(typ) == 'number' and typ % 1 == 0, 'main.animations.skin_slide_animation.SkinSlideAnimation')
      assert(type(reveal) == 'boolean', 'main.animations.skin_slide_animation.SkinSlideAnimation')
      local skin = SKIN:GetMeter('SlotsBackground')
      local beginAction = nil
      local finishAction = nil
      if reveal then
        beginAction = function(self)
          STATE.SKIN_ANIMATION_PLAYING = true
          return SKIN:Bang('[!HideMeter "SkinEnabler"][!UpdateMeter "SkinEnabler"]')
        end
        finishAction = function(self)
          SKIN:Bang('[!ShowMeter "SlotAnimation"][!UpdateMeter "SlotAnimation"]')
          SKIN:Bang('[!ShowMeter "ToolbarEnabler"][!UpdateMeter "ToolbarEnabler"]')
          STATE.SKIN_VISIBLE = true
          STATE.SKIN_ANIMATION_PLAYING = false
        end
      else
        beginAction = function(self)
          STATE.SKIN_ANIMATION_PLAYING = true
          STATE.SKIN_VISIBLE = false
          SKIN:Bang('[!HideMeter "SlotAnimation"][!UpdateMeter "SlotAnimation"]')
          return SKIN:Bang('[!HideMeter "ToolbarEnabler"][!UpdateMeter "ToolbarEnabler"]')
        end
        finishAction = function(self)
          setUpdateDivider(-1)
          SKIN:Bang('[!ShowMeter "SkinEnabler"][!UpdateMeter "SkinEnabler"]')
          STATE.REVEALING_DELAY = COMPONENTS.SETTINGS:getSkinRevealingDelay()
          STATE.SKIN_ANIMATION_PLAYING = false
        end
      end
      local frames = { }
      local _exp_0 = typ
      if ENUMS.SKIN_ANIMATIONS.SLIDE_UP == _exp_0 then
        local skinY = skin:GetY()
        local skinH = skin:GetH()
        if reveal == false then
          skinH = -skinH
        end
        frames[1] = slideFrame('Y', skinY, skinH, 1 / 20.0)
        frames[2] = slideFrame('Y', skinY, skinH, 1 / 12.0)
        frames[3] = slideFrame('Y', skinY, skinH, 1 / 4.0)
        frames[4] = slideFrame('Y', skinY, skinH, 1 / 2.5)
        frames[5] = slideFrame('Y', skinY, skinH, 1 / 1.8)
        frames[6] = slideFrame('Y', skinY, skinH, 1)
      elseif ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT == _exp_0 then
        local skinX = skin:GetX()
        local skinW = skin:GetW()
        if reveal == true then
          skinW = -skinW
        end
        frames[1] = slideFrame('X', skinX, skinW, 1 / 20.0)
        frames[2] = slideFrame('X', skinX, skinW, 1 / 12.0)
        frames[3] = slideFrame('X', skinX, skinW, 1 / 4.0)
        frames[4] = slideFrame('X', skinX, skinW, 1 / 2.5)
        frames[5] = slideFrame('X', skinX, skinW, 1 / 1.8)
        frames[6] = slideFrame('X', skinX, skinW, 1)
      elseif ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN == _exp_0 then
        local skinY = skin:GetY()
        local skinH = skin:GetH()
        if reveal == true then
          skinH = -skinH
        end
        frames[1] = slideFrame('Y', skinY, skinH, 1 / 20.0)
        frames[2] = slideFrame('Y', skinY, skinH, 1 / 12.0)
        frames[3] = slideFrame('Y', skinY, skinH, 1 / 4.0)
        frames[4] = slideFrame('Y', skinY, skinH, 1 / 2.5)
        frames[5] = slideFrame('Y', skinY, skinH, 1 / 1.8)
        frames[6] = slideFrame('Y', skinY, skinH, 1)
      elseif ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT == _exp_0 then
        local skinX = skin:GetX()
        local skinW = skin:GetW()
        if reveal == false then
          skinW = -skinW
        end
        frames[1] = slideFrame('X', skinX, skinW, 1 / 20.0)
        frames[2] = slideFrame('X', skinX, skinW, 1 / 12.0)
        frames[3] = slideFrame('X', skinX, skinW, 1 / 4.0)
        frames[4] = slideFrame('X', skinX, skinW, 1 / 2.5)
        frames[5] = slideFrame('X', skinX, skinW, 1 / 1.8)
        frames[6] = slideFrame('X', skinX, skinW, 1)
      else
        assert(nil, 'main.animations.skin_slide_animation.SkinSlideAnimation')
      end
      local args = {
        beginAction = beginAction,
        finishAction = finishAction,
        frames = frames,
        mandatory = true,
        resetAction = nil
      }
      return _class_0.__parent.__init(self, args)
    end,
    __base = _base_0,
    __name = "SkinSlideAnimation",
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
  SkinSlideAnimation = _class_0
end
return SkinSlideAnimation
