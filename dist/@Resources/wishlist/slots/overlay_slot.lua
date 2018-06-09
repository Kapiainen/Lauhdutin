local OverlaySlot
do
  local _class_0
  local _base_0 = {
    show = function(self, index, game)
      if not (self.contextSensitive) then
        return 
      end
      if not (game) then
        self:hide()
        return 
      end
      log(('Showing overlay for %s'):format(game:getTitle()))
      local image = nil
      local upperText = ''
      local lowerText = ''
      local platformID = game:getPlatformID()
      local _exp_0 = STATE.LEFT_CLICK_ACTION
      if ENUMS.LEFT_CLICK_ACTIONS.OPEN_STORE_PAGE == _exp_0 then
        upperText = game:getTitle()
        lowerText = STATE.PLATFORM_NAMES[platformID]
      else
        assert(nil, 'wishlist.slots.overlay_slot.show')
      end
      if image then
        SKIN:Bang(('[!SetOption "SlotOverlayImage" "ImageName" "#@#main\\gfx\\%s"]'):format(image))
      else
        SKIN:Bang('[!SetOption "SlotOverlayImage" "ImageName" ""]')
      end
      local price = ''
      local basePrice = game:getBasePrice()
      local finalPrice = game:getFinalPrice()
      local discount = game:getDiscountPercentage()
      local isFree = game:getFree()
      local isPrerelease = game:getPrerelease()
      if isPrerelease then
        price = self.comingSoon
      elseif isFree then
        price = self.free
      elseif discount > 0 then
        price = ('%s (-%d%%)'):format(finalPrice, discount)
      else
        price = finalPrice
      end
      local text = ('%s#CRLF##CRLF#%s#CRLF##CRLF#%s'):format(utility.replaceUnsupportedChars(upperText), price, utility.replaceUnsupportedChars(lowerText))
      SKIN:Bang(('[!SetOption "SlotOverlayText" "Text" "%s"]'):format(text))
      local slot = SKIN:GetMeter(('Slot%dImage'):format(index))
      SKIN:Bang(('[!SetOption "SlotOverlayImage" "X" "%d"]'):format(slot:GetX()))
      SKIN:Bang(('[!SetOption "SlotOverlayImage" "Y" "%d"]'):format(slot:GetY()))
      SKIN:Bang('[!ShowMeterGroup "SlotOverlay"]')
      return SKIN:Bang('[!UpdateMeterGroup "SlotOverlay"]')
    end,
    hide = function(self)
      SKIN:Bang('[!HideMeterGroup "SlotOverlay"]')
      return SKIN:Bang('[!UpdateMeterGroup "SlotOverlay"]')
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, settings)
      assert(type(settings) == 'table', 'wishlist.slots.overlay_slot.OverlaySlot')
      self.contextSensitive = settings:getSlotsOverlayEnabled()
      self.free = LOCALIZATION:get('overlay_free', 'Free')
      self.comingSoon = LOCALIZATION:get('overlay_coming_soon', 'Coming soon')
    end,
    __base = _base_0,
    __name = "OverlaySlot"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  OverlaySlot = _class_0
end
return OverlaySlot
