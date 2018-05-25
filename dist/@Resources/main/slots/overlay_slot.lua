local utility = require('shared.utility')
local images = {
  play = 'overlay_slot_play.png',
  error = 'overlay_slot_error.png',
  hide = 'overlay_slot_hide.png',
  unhide = 'overlay_slot_unhide.png',
  install = 'overlay_slot_install.png',
  uninstall = 'overlay_slot_uninstall.png'
}
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
      local image = images.play
      local info = ''
      local platformID = game:getPlatformID()
      local _exp_0 = STATE.LEFT_CLICK_ACTION
      if ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME == _exp_0 then
        if game:isVisible() == false then
          info = self.alreadyHidden
        else
          info = self.hideGame
        end
        image = images.hide
      elseif ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME == _exp_0 then
        if game:isVisible() == true then
          info = self.alreadyVisible
        else
          info = self.unhideGame
        end
        image = images.unhide
      elseif ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME == _exp_0 then
        if STATE.PLATFORM_RUNNING_STATUS[platformID] == false then
          info = self.platformNotRunning:format(STATE.PLATFORM_NAMES[platformID])
          image = images.error
        elseif game:isInstalled() == false then
          if (platformID == ENUMS.PLATFORM_IDS.STEAM or platformID == ENUMS.PLATFORM_IDS.BATTLENET) then
            info = self.installGame
            image = images.install
          else
            info = self.uninstalledGame
            image = images.error
          end
        end
      elseif ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME == _exp_0 then
        info = self.removeGame
        image = images.error
      else
        assert(nil, 'main.slots.overlay_slot.show')
      end
      if image then
        SKIN:Bang(('[!SetOption "SlotOverlayImage" "ImageName" "#@#main\\gfx\\%s"]'):format(image))
      else
        SKIN:Bang('[!SetOption "SlotOverlayImage" "ImageName" ""]')
      end
      if info == '' then
        local numHoursPlayed = math.round(game:getHoursPlayed())
        if numHoursPlayed == 1 then
          info = self.singleHourPlayed:format(numHoursPlayed)
        else
          info = self.hoursPlayed:format(numHoursPlayed)
        end
      end
      local text = ('%s#CRLF##CRLF##CRLF##CRLF#%s'):format(utility.replaceUnsupportedChars(game:getTitle()), info)
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
      assert(type(settings) == 'table', 'main.slots.overlay_slot.OverlaySlot')
      self.contextSensitive = settings:getSlotsOverlayEnabled()
      self.platformNotRunning = LOCALIZATION:get('overlay_platform_not_running', '%s is not running')
      self.hoursPlayed = LOCALIZATION:get('overlay_hours_played', '%.0f hours played')
      self.singleHourPlayed = LOCALIZATION:get('overlay_single_hour_played', '%.0f hour played')
      self.installGame = LOCALIZATION:get('overlay_install', 'Install')
      self.hideGame = LOCALIZATION:get('overlay_hide', 'Hide')
      self.alreadyHidden = LOCALIZATION:get('overlay_already_hidden', 'Already hidden')
      self.unhideGame = LOCALIZATION:get('overlay_unhide', 'Unhide')
      self.alreadyVisible = LOCALIZATION:get('overlay_already_visible', 'Already visible')
      self.removeGame = LOCALIZATION:get('overlay_remove', 'Remove')
      self.uninstalledGame = LOCALIZATION:get('overlay_uninstalled', 'Uninstalled')
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
