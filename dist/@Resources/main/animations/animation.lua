local Animation
do
  local _class_0
  local _base_0 = {
    play = function(self)
      self.currentFrame = self.currentFrame + 1
      if self.currentFrame <= self.numFrames then
        if self.currentFrame == 1 and self.beginAction ~= nil then
          self:beginAction()
        end
        local bangs = self.frames[self.currentFrame]
        for _index_0 = 1, #bangs do
          local bang = bangs[_index_0]
          SKIN:Bang(bang)
        end
        if self.currentFrame == self.numFrames then
          return self:finish()
        end
      end
    end,
    finish = function(self)
      if self.resetAction ~= nil then
        self:resetAction()
      end
      if self.finishAction ~= nil then
        return self:finishAction()
      end
    end,
    hasFinished = function(self)
      return self.currentFrame >= self.numFrames
    end,
    cancel = function(self)
      if self:isMandatory() then
        return 
      end
      self.currentFrame = self.numFrames
    end,
    isMandatory = function(self)
      return self.mandatory == true
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, args)
      assert(type(args) == 'table', 'animations.animation.Animation')
      assert(type(args.frames) == 'table', 'animations.animation.Animation')
      assert(#args.frames > 0, 'animations.animation.Animation')
      assert(args.beginAction == nil or type(args.beginAction) == 'function', 'animations.animation.Animation')
      assert(args.resetAction == nil or type(args.resetAction) == 'function', 'animations.animation.Animation')
      assert(args.finishAction == nil or type(args.finishAction) == 'function', 'animations.animation.Animation')
      assert(args.mandatory == nil or type(args.mandatory) == 'boolean', 'animations.animation.Animation')
      self.frames = args.frames
      self.numFrames = #self.frames
      self.currentFrame = 0
      self.beginAction = args.beginAction
      self.resetAction = args.resetAction
      self.finishAction = args.finishAction
      self.mandatory = args.mandatory
    end,
    __base = _base_0,
    __name = "Animation"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Animation = _class_0
end
return Animation
