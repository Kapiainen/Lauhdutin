queue = nil
downloadFolder = nil
outputFile = nil
outputFolder = nil
finishCallback = nil
errorCallback = nil
callbackArgs = nil

stop = () ->
	SKIN\Bang('[!SetOption "Downloader" "UpdateDivider" "-1"]')
	SKIN\Bang('[!SetOption "Downloader" "Disabled" "1"]')
	SKIN\Bang('[!UpdateMeasure "Downloader"]')

start = () ->
	return false if #queue == 0
	args = table.remove(queue)
	outputFile = args.outputFile
	outputFolder = args.outputFolder
	finishCallback = args.finishCallback
	errorCallback = args.errorCallback
	callbackArgs = args.callbackArgs
	log('Downloading:', args.url, args.outputFolder, args.outputFile)
	SKIN\Bang(('[!SetOption "Downloader" "URL" "%s"]')\format(args.url))
	SKIN\Bang(('[!SetOption "Downloader" "DownloadFile" "%s"]')\format(args.outputFile))
	SKIN\Bang('[!SetOption "Downloader" "FinishAction" "[!CommandMeasure Script OnDownloaderSucceeded()]"]')
	SKIN\Bang('[!SetOption "Downloader" "OnConnectErrorAction" "[!CommandMeasure Script OnDownloaderFailed()]"]')
	SKIN\Bang('[!SetOption "Downloader" "OnRegExpErrorAction" "[!CommandMeasure Script OnDownloaderFailed()]"]')
	SKIN\Bang('[!SetOption "Downloader" "OnDownloadErrorAction" "[!CommandMeasure Script OnDownloaderFailed()]"]')
	SKIN\Bang('[!SetOption "Downloader" "UpdateDivider" "63"]')
	SKIN\Bang('[!SetOption "Downloader" "Disabled" "0"]')
	SKIN\Bang('[!UpdateMeasure "Downloader"]')
	return true

class Downloader
	new: () =>
		assert(SKIN\GetMeasure('Downloader') ~= nil, 'shared.downloader.Downloader.new')
		downloadFolder = io.joinPaths(SKIN\GetVariable('CURRENTPATH'), 'DownloadFile')
		queue = {}

	push: (args) =>
		assert(type(args.url) == 'string', 'shared.downloader.Downloader.push')
		assert(type(args.outputFile) == 'string', 'shared.downloader.Downloader.push')
		assert(type(args.outputFolder) == 'string', 'shared.downloader.Downloader.push')
		assert(args.finishCallback == nil or type(args.finishCallback) == 'function', 'shared.downloader.Downloader.push')
		assert(args.errorCallback == nil or type(args.errorCallback) == 'function', 'shared.downloader.Downloader.push')
		table.insert(queue, args)

	start: () => start()

export OnDownloaderSucceeded = () ->
	stop()
	log('Successfully downloaded!')
	downloadPath = io.joinPaths(downloadFolder, outputFile)
	finalPath = io.absolutePath(io.joinPaths(outputFolder, outputFile))
	if io.fileExists(finalPath, false)
		os.remove(finalPath)
	if io.fileExists(downloadPath, false)
		os.rename(downloadPath, finalPath)
	callback = finishCallback
	if callback ~= nil
		callback(callbackArgs)
	start()

export OnDownloaderFailed = () ->
	stop()
	log('Failed to download!')
	callback = errorCallback
	if callback ~= nil
		callback(callbackArgs)
	start()

return Downloader
