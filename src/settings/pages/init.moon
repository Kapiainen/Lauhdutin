class Pages
	new: () =>
		@pages = {
			require('settings.pages.skin')()
			require('settings.pages.shortcuts')()
			require('settings.pages.steam')()
			require('settings.pages.battlenet')()
			require('settings.pages.gog_galaxy')()
		}
		@currentPage = nil

	getCount: () => return #@pages

	loadPage: (index) =>
		assert(type(index) == 'number' and index % 1 == 0, '"Pages.loadPage" expected "index" to be an integer.')
		assert(index > 0 and index <= @getCount(), ('"Pages.loadPage" expected "index" to be between 1 and %d, but instead got %d.')\format(@getCount(), index))
		@currentPage = @pages[index]
		return @currentPage\getTitle(), @currentPage\getSettings()

return Pages
