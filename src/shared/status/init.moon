class Status
	new: () =>
		@visible = true
		@exception = false

	update: () => SKIN\Bang('[!UpdateMeter "StatusMessage"]')

	show: (message, exception = false) =>
		assert(type(message) == 'string', 'shared.status.init.Status')
		SKIN\Bang('[!ShowMeter "StatusMessage"]') unless @visible
		@visible = true
		if exception
			@exception = true
			starts, ends = message\find('%[string ""%]:')
			message = 'Line ' .. message\sub(ends + 1) if ends
		message = message\gsub('\"', '\'\'')
		if exception
			SKIN\Bang(('[!Log "Error: %s" "Error"]')\format(message))
			message = ('Error:#CRLF#%s')\format(message)
		else
			log(message)
		SKIN\Bang(('[!SetOption "StatusMessage" "Text" "%s"]')\format(message))
		@update()

	hide: () =>
		return unless @visible
		return if @exception
		@visible = false
		SKIN\Bang('[!HideMeter "StatusMessage"]')
		@update()

return Status
