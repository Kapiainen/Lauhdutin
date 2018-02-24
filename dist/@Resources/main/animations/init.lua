local Animation = require('main.animations.animation')
local SlotHoverAnimation = require('main.animations.slot_hover_animation')
local SlotClickAnimation = require('main.animations.slot_click_animation')
local SkinSlideAnimation = require('main.animations.skin_slide_animation')
local AnimationQueue
do
  local _class_0
  local _base_0 = {
    push = function(self, animation)
      if #self.queue > 0 then
        if not (self.queue[1]:isMandatory()) then
          self.queue[1]:cancel()
        end
        local i = 2
        while i <= #self.queue do
          if not (self.queue[i]:isMandatory()) then
            table.remove(self.queue, i)
          else
            i = i + 1
          end
        end
      end
      return table.insert(self.queue, animation)
    end,
    pushSlotHover = function(self, index, animationType, banner)
      if animationType <= ENUMS.SLOT_HOVER_ANIMATIONS.NONE or animationType >= ENUMS.SLOT_HOVER_ANIMATIONS.MAX then
        return 
      end
      if STATE.SKIN_ANIMATION_PLAYING then
        return 
      end
      if not (STATE.SKIN_VISIBLE) then
        return 
      end
      return self:push(SlotHoverAnimation(index, animationType, banner))
    end,
    pushSlotClick = function(self, index, animationType, action, game)
      if animationType <= ENUMS.SLOT_CLICK_ANIMATIONS.NONE or animationType >= ENUMS.SLOT_CLICK_ANIMATIONS.MAX then
        return false
      end
      if STATE.SKIN_ANIMATION_PLAYING then
        return 
      end
      if not (STATE.SKIN_VISIBLE) then
        return 
      end
      local banner = game:getBanner()
      if banner == nil then
        return false
      end
      self:push(SlotClickAnimation(index, animationType, action, game, banner))
      return true
    end,
    pushSkinSlide = function(self, animationType, reveal)
      if animationType <= ENUMS.SKIN_ANIMATIONS.NONE or animationType >= ENUMS.SKIN_ANIMATIONS.MAX then
        return false
      end
      if STATE.SKIN_ANIMATION_PLAYING then
        return 
      end
      if reveal and STATE.SKIN_VISIBLE then
        return 
      end
      if not reveal and not STATE.SKIN_VISIBLE then
        return 
      end
      self:push(SkinSlideAnimation(animationType, reveal))
      return true
    end,
    play = function(self)
      if #self.queue < 1 then
        return 
      end
      self.queue[1]:play()
      if self.queue[1] ~= nil and self.queue[1]:hasFinished() then
        return table.remove(self.queue, 1)
      end
    end,
    updateSlot = function(self, index)
      if index < 1 then
        return 
      end
      if COMPONENTS.SETTINGS:getSlotsHoverAnimation() == ENUMS.SLOT_HOVER_ANIMATIONS.NONE then
        return 
      end
      local game = COMPONENTS.SLOTS:getGame(index)
      if game == nil then
        return 
      end
      local banner = game:getBanner()
      if banner == nil then
        return 
      end
      SKIN:Bang(('[!SetOption "SlotAnimation" "ImageName" "#@#%s"]'):format(banner))
      return SKIN:Bang('[!UpdateMeter "SlotAnimation"]')
    end,
    resetSlots = function(self)
      local animationType = COMPONENTS.SETTINGS:getSlotsHoverAnimation()
      if animationType <= ENUMS.SLOT_HOVER_ANIMATIONS.NONE or animationType >= ENUMS.SLOT_HOVER_ANIMATIONS.MAX then
        return 
      end
      SKIN:Bang('[!ShowMeterGroup "Slots"]')
      SKIN:Bang('[!SetOption "SlotsBackgroundCutout" "Shape2" "Rectangle 0,0,0,0 | StrokeWidth 0"]')
      return SKIN:Bang('[!UpdateMeter "SlotsBackgroundCutout"][!ShowMeterGroup "Slots"]')
    end,
    cancelAnimations = function(self)
      local animationType = COMPONENTS.SETTINGS:getSlotsHoverAnimation()
      if animationType <= ENUMS.SLOT_HOVER_ANIMATIONS.NONE or animationType >= ENUMS.SLOT_HOVER_ANIMATIONS.MAX then
        return 
      end
      local i = 2
      while i <= #self.queue do
        if not (self.queue[i]:isMandatory()) then
          table.remove(self.queue, i)
        else
          i = i + 1
        end
      end
      if self.queue[1] ~= nil and not self.queue[1]:isMandatory() then
        return self.queue[1]:cancel()
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.queue = { }
    end,
    __base = _base_0,
    __name = "AnimationQueue"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  AnimationQueue = _class_0
end
return AnimationQueue
