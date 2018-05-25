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
		assert(type(index) == 'number' and index % 1 == 0, 'settings.pages.init.Pages.loadPage')
		assert(index > 0 and index <= @getCount(), 'settings.pages.init.Pages.loadPage')
		@currentPage = @pages[index]
		return @currentPage\getTitle(), @currentPage\getSettings()

return Pages
