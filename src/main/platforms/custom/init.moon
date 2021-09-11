Platform = require('main.platforms.platform')

-- Used for games that are manually added via the NewGame config.

class Custom extends Platform
	new: (settings) =>
		super(settings)
		@platformID = ENUMS.PLATFORM_IDS.CUSTOM
		@name = LOCALIZATION\get('platform_name_custom', 'Custom')
		@cachePath = 'cache\\custom\\'
		@enabled = true

	validate: () => return

	detectBanners: (oldGames) =>
		for game in *oldGames
			if game\getPlatformID() == ENUMS.PLATFORM_IDS.CUSTOM
				path = game\getBanner()
				if path ~= nil and not io.fileExists(path)
					game\setBanner(nil)
				elseif path == nil
					game\setBanner(@getBannerPath(game\getExpectedBanner()))

return Custom
