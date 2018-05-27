export Initialize = () ->
	export startTime = os.time()

export Update = () ->
	sessionTime = os.time() - startTime
	hours = sessionTime / 3600.0
	minutes = (hours % 1) * 60.0
	SKIN\Bang(('[!SetOption "SessionTime" "Text" "%02d:%02d"]')\format(math.floor(hours), math.floor(minutes)))
