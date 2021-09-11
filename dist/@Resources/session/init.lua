Initialize = function()
  startTime = os.time()
end
Update = function()
  local sessionTime = os.time() - startTime
  local hours = sessionTime / 3600.0
  local minutes = (hours % 1) * 60.0
  return SKIN:Bang(('[!SetOption "SessionTime" "Text" "%02d:%02d"]'):format(math.floor(hours), math.floor(minutes)))
end
