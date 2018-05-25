class Page
	new: () =>
		@title = 'UNDEFINED'
		@settings = {}

	getTitle: () => return @title

	getSettings: () => return @settings

return Page
