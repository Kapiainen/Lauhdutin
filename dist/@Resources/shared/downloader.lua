local queue = nil
local downloadFolder = nil
local outputFile = nil
local outputFolder = nil
local finishCallback = nil
local errorCallback = nil
local callbackArgs = nil
local stop
stop = function()
  SKIN:Bang('[!SetOption "Downloader" "UpdateDivider" "-1"]')
  SKIN:Bang('[!SetOption "Downloader" "Disabled" "1"]')
  return SKIN:Bang('[!UpdateMeasure "Downloader"]')
end
local start
start = function()
  if #queue == 0 then
    return false
  end
  local args = table.remove(queue)
  outputFile = args.outputFile
  outputFolder = args.outputFolder
  finishCallback = args.finishCallback
  errorCallback = args.errorCallback
  callbackArgs = args.callbackArgs
  log('Downloading:', args.url, args.outputFolder, args.outputFile)
  SKIN:Bang(('[!SetOption "Downloader" "URL" "%s"]'):format(args.url))
  SKIN:Bang(('[!SetOption "Downloader" "DownloadFile" "%s"]'):format(args.outputFile))
  SKIN:Bang('[!SetOption "Downloader" "FinishAction" "[!CommandMeasure Script OnDownloaderSucceeded()]"]')
  SKIN:Bang('[!SetOption "Downloader" "OnConnectErrorAction" "[!CommandMeasure Script OnDownloaderFailed()]"]')
  SKIN:Bang('[!SetOption "Downloader" "OnRegExpErrorAction" "[!CommandMeasure Script OnDownloaderFailed()]"]')
  SKIN:Bang('[!SetOption "Downloader" "OnDownloadErrorAction" "[!CommandMeasure Script OnDownloaderFailed()]"]')
  SKIN:Bang('[!SetOption "Downloader" "UpdateDivider" "63"]')
  SKIN:Bang('[!SetOption "Downloader" "Disabled" "0"]')
  SKIN:Bang('[!UpdateMeasure "Downloader"]')
  return true
end
local Downloader
do
  local _class_0
  local _base_0 = {
    push = function(self, args)
      assert(type(args.url) == 'string', 'shared.downloader.Downloader.push')
      assert(type(args.outputFile) == 'string', 'shared.downloader.Downloader.push')
      assert(type(args.outputFolder) == 'string', 'shared.downloader.Downloader.push')
      assert(args.finishCallback == nil or type(args.finishCallback) == 'function', 'shared.downloader.Downloader.push')
      assert(args.errorCallback == nil or type(args.errorCallback) == 'function', 'shared.downloader.Downloader.push')
      return table.insert(queue, args)
    end,
    start = function(self)
      return start()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      assert(SKIN:GetMeasure('Downloader') ~= nil, 'shared.downloader.Downloader.new')
      downloadFolder = io.joinPaths(SKIN:GetVariable('CURRENTPATH'), 'DownloadFile')
      queue = { }
    end,
    __base = _base_0,
    __name = "Downloader"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Downloader = _class_0
end
OnDownloaderSucceeded = function()
  stop()
  log('Successfully downloaded!')
  local downloadPath = io.joinPaths(downloadFolder, outputFile)
  local finalPath = io.absolutePath(io.joinPaths(outputFolder, outputFile))
  if io.fileExists(finalPath, false) then
    os.remove(finalPath)
  end
  if io.fileExists(downloadPath, false) then
    os.rename(downloadPath, finalPath)
  end
  local callback = finishCallback
  if callback ~= nil then
    callback(callbackArgs)
  end
  return start()
end
OnDownloaderFailed = function()
  stop()
  log('Failed to download!')
  local callback = errorCallback
  if callback ~= nil then
    callback(callbackArgs)
  end
  return start()
end
return Downloader
