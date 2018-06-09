require('main.events.slots')
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
  local success, err = pcall(function() end)
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
