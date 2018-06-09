OnSteamWishlistDownloaded = function()
  local success, err = pcall(function()
    log('Successfully downloaded Steam wishlist')
    utility.stopDownloader()
    local downloadedPath = io.joinPaths(STATE.PATHS.DOWNLOADFILE, 'wishlist.txt')
    local cachedPath = io.joinPaths(STATE.PATHS.RESOURCES, STATE.PLATFORM_QUEUE[1]:getCachePath(), 'wishlist.txt')
    if io.fileExists(downloadedPath, false) and io.fileExists(cachedPath, false) then
      os.remove(cachedPath)
      os.rename(downloadedPath, cachedPath)
    end
    local wishlist = ''
    if io.fileExists(cachedPath, false) then
      wishlist = io.readFile(cachedPath, false)
    end
    STATE.PLATFORM_QUEUE[1]:parseWishlist(wishlist)
    return OnFinishedDownloadingWishlists()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnSteamWishlistDownloadFailed = function()
  local success, err = pcall(function()
    log('Failed to download Steam wishlist')
    utility.stopDownloader()
    return OnFinishedDownloadingWishlists()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
