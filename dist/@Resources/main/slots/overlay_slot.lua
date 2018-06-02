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
      local upperText = ''
      local lowerText = ''
      local platformID = game:getPlatformID()
      local _exp_0 = STATE.LEFT_CLICK_ACTION
      if ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME == _exp_0 then
        upperText = game:getTitle()
        if game:isVisible() == false then
          lowerText = self.alreadyHidden
        else
          lowerText = self.hideGame
        end
        image = images.hide
      elseif ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME == _exp_0 then
        upperText = game:getTitle()
        if game:isVisible() == true then
          lowerText = self.alreadyVisible
        else
          lowerText = self.unhideGame
        end
        image = images.unhide
      elseif ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME == _exp_0 then
        if STATE.PLATFORM_RUNNING_STATUS[platformID] == false then
          upperText = game:getTitle()
          lowerText = self.platformNotRunning:format(STATE.PLATFORM_NAMES[platformID])
          image = images.error
        elseif game:isInstalled() == false then
          upperText = game:getTitle()
          if platformID == ENUMS.PLATFORM_IDS.STEAM and game:getPlatformOverride() == nil then
            lowerText = self.installGame
            image = images.install
          else
            lowerText = self.uninstalledGame
            image = images.error
          end
        else
          if self.getUpperText ~= nil then
            upperText = self:getUpperText(game)
          end
          if self.getLowerText ~= nil then
            lowerText = self:getLowerText(game)
          end
        end
      elseif ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME == _exp_0 then
        upperText = game:getTitle()
        lowerText = self.removeGame
        image = images.error
      else
        assert(nil, 'main.slots.overlay_slot.show')
      end
      if image then
        SKIN:Bang(('[!SetOption "SlotOverlayImage" "ImageName" "#@#main\\gfx\\%s"]'):format(image))
      else
        SKIN:Bang('[!SetOption "SlotOverlayImage" "ImageName" ""]')
      end
      local text = ('%s#CRLF##CRLF##CRLF##CRLF#%s'):format(utility.replaceUnsupportedChars(upperText), utility.replaceUnsupportedChars(lowerText))
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
      self.multipleHoursPlayed = LOCALIZATION:get('overlay_hours_played', '%.0f hours played')
      self.singleHourPlayed = LOCALIZATION:get('overlay_single_hour_played', '%.0f hour played')
      self.singleHourSingleMinutePlayed = LOCALIZATION:get('overlay_single_hour_single_minute_played', '%.0f hour %.0f minute played')
      self.singleHourMultipleMinutesPlayed = LOCALIZATION:get('overlay_single_hour_multiple_minute_played', '%.0f hour %.0f minutes played')
      self.multipleHoursSingleMinutePlayed = LOCALIZATION:get('overlay_multiple_hour_single_minute_played', '%.0f hours %.0f minute played')
      self.multipleHoursMultipleMinutesPlayed = LOCALIZATION:get('overlay_multiple_hour_multiple_minute_played', '%.0f hours %.0f minutes played')
      self.singleMinutePlayed = LOCALIZATION:get('overlay_single_minute_played', '%.0f minute played')
      self.multipleMinutesPlayed = LOCALIZATION:get('overlay_multiple_minutes_played', '%.0f minutes played')
      self.installGame = LOCALIZATION:get('overlay_install', 'Install')
      self.hideGame = LOCALIZATION:get('overlay_hide', 'Hide')
      self.alreadyHidden = LOCALIZATION:get('overlay_already_hidden', 'Already hidden')
      self.unhideGame = LOCALIZATION:get('overlay_unhide', 'Unhide')
      self.alreadyVisible = LOCALIZATION:get('overlay_already_visible', 'Already visible')
      self.removeGame = LOCALIZATION:get('overlay_remove', 'Remove')
      self.uninstalledGame = LOCALIZATION:get('overlay_uninstalled', 'Uninstalled')
      local textOptions = { }
      textOptions[ENUMS.OVERLAY_SLOT_TEXT.GAME_TITLE] = function(self, game)
        return game:getTitle()
      end
      textOptions[ENUMS.OVERLAY_SLOT_TEXT.GAME_PLATFORM] = function(self, game)
        return STATE.PLATFORM_NAMES[game:getPlatformID()]
      end
      textOptions[ENUMS.OVERLAY_SLOT_TEXT.TIME_PLAYED_HOURS] = function(self, game)
        local numHoursPlayed = math.round(game:getHoursPlayed())
        if numHoursPlayed == 1 then
          return self.singleHourPlayed:format(numHoursPlayed)
        end
        return self.multipleHoursPlayed:format(numHoursPlayed)
      end
      textOptions[ENUMS.OVERLAY_SLOT_TEXT.TIME_PLAYED_HOURS_AND_MINUTES] = function(self, game)
        local hoursPlayed = game:getHoursPlayed()
        local numHoursPlayed = math.floor(hoursPlayed)
        local numMinutesPlayed = math.round((hoursPlayed - numHoursPlayed) * 60.0)
        if numHoursPlayed == 1 then
          if numMinutesPlayed == 1 then
            return self.singleHourSingleMinutePlayed:format(numHoursPlayed, numMinutesPlayed)
          end
          return self.singleHourMultipleMinutesPlayed:format(numHoursPlayed, numMinutesPlayed)
        end
        if numMinutesPlayed == 1 then
          return self.multipleHoursSingleMinutePlayed:format(numHoursPlayed, numMinutesPlayed)
        end
        return self.multipleHoursMultipleMinutesPlayed:format(numHoursPlayed, numMinutesPlayed)
      end
      textOptions[ENUMS.OVERLAY_SLOT_TEXT.TIME_PLAYED_HOURS_OR_MINUTES] = function(self, game)
        local hoursPlayed = game:getHoursPlayed()
        if hoursPlayed >= 1.0 and hoursPlayed < 1.5 then
          return self.singleHourPlayed:format(math.floor(hoursPlayed))
        elseif hoursPlayed >= 1.5 then
          return self.multipleHoursPlayed:format(math.round(hoursPlayed))
        end
        local numMinutesPlayed = math.round((hoursPlayed - math.floor(hoursPlayed)) * 60.0)
        if numMinutesPlayed == 1 then
          return self.singleMinutePlayed:format(numMinutesPlayed)
        end
        return self.multipleMinutesPlayed:format(numMinutesPlayed)
      end
      textOptions[ENUMS.OVERLAY_SLOT_TEXT.LAST_PLAYED_YYYYMMDD] = function(self, game)
        local lastPlayed = game:getLastPlayed()
        if lastPlayed > 315532800 then
          local date = os.date('*t', lastPlayed)
          return ('%04.f-%02.f-%02.f'):format(date.year, date.month, date.day)
        end
        return ''
      end
      textOptions[ENUMS.OVERLAY_SLOT_TEXT.NOTES] = function(self, game)
        local notes = game:getNotes()
        if notes == nil then
          return ''
        end
        return notes
      end
      self.getUpperText = textOptions[settings:getSlotsOverlayUpperText()]
      self.getLowerText = textOptions[settings:getSlotsOverlayLowerText()]
      if settings:getSlotsOverlayImagesEnabled() ~= true then
        images = { }
      end
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
