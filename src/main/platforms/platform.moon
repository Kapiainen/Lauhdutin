utility = require('shared.utility')
Game = require('main.game')

class Platform
	new: (settings) =>
		assert(type(settings) == 'table', 'main.platforms.platform.Platform')
		@bannerExtensions = {
			'.jpg'
			'.png'
		}
		return

	isEnabled: () => return @enabled == true

	getPlatformID: () => return @platformID

	getPlatformProcess: () => return @platformProcess

	getName: () => return @name

	getWaitCommand: () => return utility.waitCommand

	getGames: () => return @games or {}

	getBannerPath: (fileWithoutExtension, bannerPath = @cachePath) =>
		pathWithoutExtension = io.joinPaths(bannerPath, fileWithoutExtension)
		for extension in *@bannerExtensions
			path = pathWithoutExtension .. extension
			return path if io.fileExists(path)
		return nil

	getBannerExtensions: () => return @bannerExtensions

return Platform
