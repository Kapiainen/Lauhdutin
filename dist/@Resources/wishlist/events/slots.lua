require('main.events.slots')
local openStorePage
openStorePage = function(game)
  return COMPONENTS.PROCESS:getActiveProcesses(game:getGameID())
end
OnLeftClickSlot = function(index)
  if not (STATE.INITIALIZED) then
    return 
  end
  if STATE.SKIN_ANIMATION_PLAYING then
    return 
  end
  if index < 1 or index > STATE.NUM_SLOTS then
    return 
  end
  local success, err = pcall(function()
    local game = COMPONENTS.SLOTS:leftClick(index)
    if not (game) then
      return 
    end
    local action
    local _exp_0 = STATE.LEFT_CLICK_ACTION
    if ENUMS.LEFT_CLICK_ACTIONS.OPEN_STORE_PAGE == _exp_0 then
      action = openStorePage
    else
      action = assert(nil, 'wishlist.init.OnLeftClickSlot')
    end
    if not (action) then
      return 
    end
    return action(game)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnMiddleClickSlot = function(index)
  if not (STATE.INITIALIZED) then
    return 
  end
  if STATE.SKIN_ANIMATION_PLAYING then
    return 
  end
  if index < 1 or index > STATE.NUM_SLOTS then
    return 
  end
  local success, err = pcall(function() end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
