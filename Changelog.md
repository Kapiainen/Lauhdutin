**Version 3.0.0 beta 2 - 2018/MM/DD:**
- Fixed a bug that caused an error when the number of slots in the .inc file is greater than the number of slots based on the settings.
- Game class constructor now checks if the platform ID is valid.
- Game class constructor now checks if a banner path was provided along with a banner URL.

**Version 3.0.0 beta 1 - 2018/02/25:**
- Rewritten in MoonScript/Lua, VBScript, and batch files.

**Version 2.7.1 - 2017/05/29:**
- Updated to support GOG Galaxy 1.2.x.

**Version 2.7.0 - 2017/05/15:**
- Major GUI overhaul and optimizations.
- Added support for multiple rows/columns of slots.
- Added animations for sliding the entire skin into and out of view along any of the four edges of a monitor.
- Added sorting icon for score/ranking based sorting when using fuzzy search.
- Added support for automatically (un)loading banners when skin animations are used and the skin is (not) visible in order to reduce the memory footprint.
- Added a menu, which can be accessed by middle-mouse clicking on a slot, to provide access to features and settings on a game-by-game basis.
- Added support for adding notes to a game.
- Added support for adding tags to a game.
- Added support for defining which process to monitor for each game.
- Added support for toggling whether or not a game executes bangs.
- Added setting for whether or not new games execute bangs by default.
- Added setting for making all games execute/ignore bangs.
- Added setting for having the skin adjust its position on the z-axis automatically when inputting text to filter games.
- Added setting for showing in the slot highlight if a supported platform client is not running. Currently supports Steam and Blizzard App.
- Added setting for number of slots per row/column.
- Added setting for determining the position of the toolbar and which edge to touch to make the toolbar visible.
- Added new filters.
- Added `blizzard:<argument>` filter. The old `battlenet:<argument>` filter is still available, but has been deprecated and will eventually be removed, if necessary.
- Added reversed sorting icons and refactored relevant code.
- Added support for using custom grid images assigned in Steam to native Steam games and non-Steam shortcuts.
- Added support for one level of subfolders in Windows shortcuts. The name of the subfolder that contains the shortcut is shown as the platform.
- Fixed a bug that could cause the Python backend to raise an exception when generating the final list of games.
- Fixed a bug that caused `sharedconfig.vdf` and `localconfig.vdf` files to not be processed successfully on some systems.
- Updated `Battle.net` to `Blizzard App` in the GUI.
- Updated the setting title and tooltip for the paths to Blizzard games.
- Updated the settings menu so that bangs are now edited via Notepad.
- Updated the backend so that Steam games/programs, which exist locally despite not appearing on the Steam community profile, are now hidden by default rather than ignored completely.

**Version 2.6.0 - 2017/03/15:**
- Added fuzzy search.
- Added setting for toggling fuzzy search.
- Refactored parts of the GUI script.
- Fixed a bug that caused a small portion of the toolbar to ignore left-clicks and pass them to the slot below.
- Fixed a bug, which kept the state from being automatically exited, when unhiding games so that no games remain hidden.
- Fixed a bug that prevented shortcuts to folders from working.
- GUI optimizations.
- Added more info to the terminal when there is a failure to parse a Steam community profile.
- Fixed bug that caused total hours played to fail to parse when the value was 1000+ hours.
- Simplified a setting related to Steam integration.

**Version 2.5.1 - 2017/03/06:**
- Fixed a bug that caused hover animations to not reset properly.

**Version 2.5.0 - 2017/03/06:**
- Added optional animations when clicking on a slot.
- Added optional animations when hovering the mouse over a slot.
- Added support for retaining information about games, which were previously detected and then uninstalled, for future use.
- Added button separators to the toolbar.
- Added 'R' next to the sorting icon when the sorting order is reversed.
- Updated toolbar icons.
- Updated settings skin.

**Version 2.4.0 - 2017/03/01:**
- Updated sorting of most recently played games to sort them alphabetically when timestamps are equal.
- Added sorting by total hours played.
- Added ability to reverse the order of the list of games.
- Fixed bugs that prevented generation of valid SteamIDs for certain non-Steam game shortcuts.
- Added support for .url shortcuts.
- Added context menu option for manually executing the stopping bang that is defined in the settings.
- Added support for command line arguments in Windows shortcuts.
- Added support for Battle.net games (not for classic games at the moment).
- Added `battlenet:` filter.
- Added setting for paths to folders containing Battle.net games.
- Fixed bug that caused the name of a slot's game to show up behind transparent banners.
- Fixed bug that caused an exception to be raised when processing non-Steam game shortcuts.
- Fixed bug in the parsing process for banner URLs for Battle.net games.
- GUI optimizations.

**Version 2.3.0 - 2017/02/19:**
- Added overlay art for generic errors.
- Added overlays for invalid path errors for Steam and Windows shortcuts.
- Added setting for toggling the visibility of the platform in overlays.
- Added support for executing bangs when a game starts or stops running.
- Added settings for Rainmeter bangs that should be executed when a game starts and when a game stops running.
- Updated tooltips.
- Updated names of tabs in the skin for settings.
- Minor optimization of the GUI.
- Fixed layout of input fields in the skin for settings.

**Version 2.2.0 - 2017/02/10:**
- Added support for tracking total amount of time played for most games. Will not work properly e.g. when the Battle.net client is opened instead of launching a game directly. Total time played is stored in `games.json`, which can be transferred from an older version to a newer version when updating. Supports Steam's time tracking, if a valid *SteamID64* value is specified in the settings.
- Added support for processing Steam community profiles for additional information on games (e.g. hours played). Feature can be disabled by leaving the new *SteamID64* setting blank.
- Added ability to show Steam games that are not installed. Games that are not installed are not shown by default, but they can be browsed via a context menu option or by filtering with `installed:false`. Filtering not-installed games further requires the `+` prefix. Clicking on a game that is not installed will start the normal installation process via Steam's browser protocol.
- Added context menu options for hiding and unhiding games. Toggle the corresponding option to start (un)hiding games and toggle the option again to stop. Hidden games are not shown by default, but they can be browsed via a context menu option or by filtering with `hidden:true`. Filtering hidden games further requires the `+` prefix.
- Added ability to filter out installed Steam games that the current Steam account does not have a license for. Requires that a non-blank and valid SteamID64 value is specified in the settings.
- Added highlighting to slots when the mouse is hovering over a slot. Feature can be disabled and modified via the settings menu.
- Added better handling of the scenario where no Steam games are installed, but games are discovered via the Steam community profile.
- Missing 'sharedconfig.vdf' and 'localconfig.vdf' should no longer cause no Steam games to be returned by the backend.
- Fixed bug that caused the Python path value to not be written to 'PythonPath.inc' during the initial setup.
- Fixed bug that caused certain Windows shortcuts to not show up due to not accepting valid paths that contained certain characters.
- Refactored Settings config to use relative positioning when possible.
- Refactored backend Python scripts to facilitate testing.
- Added tests for most of the Python backend scripts.
- Integrated running tests into the release process.
- Updated overlay for installing, hiding, and unhiding games.

**Version 2.1.0 - 2017/01/27:**
- Added strict minimum Python version check to backend.
- Added support for horizontal layout and a setting to toggle between vertical/horizontal layout.
- Added more messages for the status of the backend.
- Moved *Python* skin variable into a separate .inc file and added a setting for it.
- More information about backend exceptions are passed along to the skin to help with debugging and troubleshooting.
- Set UTF-8 as the encoding to use when reading files that were not generated by the skin.
- Added more print statements to the backend to help with debugging and troubleshooting.
- Fixed bug that caused the backend to return zero games from Steam despite finding more than zero games installed via Steam.

**Version 2.0.0 - 2017/01/26:**
- Implemented backend in Python 3:
    - Improved Steam support:
        - Non-Steam game shortcuts added to Steam are now fully supported and are run via the Steam browser protocol.
    - Added support for GOG Galaxy:
        - Can detect games installed via GOG Galaxy.
        - Can download banners automatically.
    - Added support for regular Windows shortcuts (.lnk).
        - Shortcuts are placed in a specific folder and a corresponding banner can be provided in another folder by the user.
- Implemented frontend in Python 3 and Lua:
    - Added secondary skin, which is accessible from the primary skin, for adjusting settings.
        - Menu is capable of showing the Steam persona name linked with the UserDataID for easier configuration.
        - Support for directory dialog when *tkinter* module is available in Python 3 environment.

**Version 1.3.3 - 2016/11/29:**
- Updated the Lua script to more gracefully handle appmanifests that do not conform to the expected structure.
- Updated the section covering the UserDataID setting in the readme.

**Version 1.3.2 - 2016/11/22:**
- Updated the URL used to download banners for games on Steam since the previous URL became obsolete and no longer successfully downloaded banners.

**Version 1.3.1 - 2016/11/05:**
- Updated the VDF parser to process the keys of all key-value pairs in case-insensitive manner. This change should fix the issue of Steam games not showing up for some people.

**Version 1.3.0 - 2015/06/06:**
- Paths to Steam libraries, which exist outside of the folder where Steam is installed, are now automatically read from libraryfolders.vdf, which exists in the SteamApps folder located in the folder where Steam is installed. The SteamLibraryPaths setting is no longer used.

**Version 1.2.1 - 2015/05/03:**
- The toolbar should now hide itself so that it is out of the way when adding games to a skin that currently has no games to show.
- Modified the patterns used when parsing VDF files in order to handle values containing quotation marks.

**Version 1.2.0 - 2015/05/01:**
- Added a new way of adding games. The "Add game" custom skin action opens a menu where one can specify the name, path to the executable, tags (optional), and Steam AppID (optional, used to download the banner) for a game.
- New settings:
  - ToolbarLogoTint
  - AddGameButtonColor
  - AddGameButtonBackgroundColor

**Version 1.1.1 - 2015/04/30:**
- Changed the way that data is retrieved from sharedconfig.vdf and localconfig.vdf.

**Version 1.1.0 - 2015/04/29:**
- Added support for additional Steam libraries that exist outside of the folder where Steam is installed.

**Version 1.0.1 - 2015/04/29:**
- Fixed a bug that caused the script to do unnecessary iterations in a for-loop that would result in an attempt to access a non-existing game object in the table of games.

**Version 1.0.0 - 2015/04/29:**
- Initial release.
