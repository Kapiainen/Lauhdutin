**Version 3.1.0 beta 4 - 2018/07/20:**
- Fixed a bug that caused buttons on the Game window to become unresponsive after trying to create a tag that already existed.

**Version 3.1.0 beta 3 - 2018/07/15:**
- Fixed a bug that caused tags, which were once assigned via a platform, to remain when later unassigned via the platform.

**Version 3.1.0 beta 2 - 2018/07/12:**
- Updated Game window to adjust its z-position when editing notes and bangs.
- Fixed a bug that prevented editing a game's notes and bangs via the Game window when the skin's path contains whitespace.

**Version 3.1.0 beta 1 - 2018/07/11:**
- Added a setting for how often games should be detected when the skin is loaded.
- Added a custom skin action to force the skin to refresh and detect games.
- Added a setting for toggling context-sensitive images in slot overlays.
- Added settings for the information to show in the upper and lower halves of the slot overlay.
- Added the ability to update a game's banner via the Game menu in case the banner has been removed or replaced with a banner with a different file extension.
- Added the ability to redownload a game's banner via the Game menu. Only available for Steam and GOG Galaxy games.
- Added the ability to open a game's store page in the system's default browser. Only available for Steam and GOG Galaxy games.
- Added the ability to invert filters (i.e. `Has notes` becomes `Does not have notes`).
- Added the ability to include uninstalled and/or hidden games in the results when searching by name among all games.
- Added an optional Session skin that shows the current system time and the current gaming session's duration in HH:MM format while playing a game. Can be enabled/disabled via a setting.
- Added a new `Custom` platform and settings for it.
- Added a new `Add a game` custom skin action, which can be used to add a game (`Custom` platform) by inputting information into a new menu.
- Added the ability to download and parse GOG profiles to get all of the games associated with that profile and any tracked amounts of time played. Requires PhantomJS.
- Added settings for toggling the use of a GOG profile and for defining the profile name.
- Updated the Game menu so that the hours played property can be modified.
- Updated the Game menu so that editable properties use the current value as the default value in the text input box.
- Updated Rainmeter helpers library.
- Updated windows to be brought to the foreground when activated.
- Fixed a bug in the Game menu where closing the menu while there was an active text input box could cause Rainmeter to freeze.
- Fixed a bug in the Filter menu that could cause scrolling to no longer function when switching between filtering all games and the current list of games (i.e. when stacking filters) without closing the menu first.
- Fixed a bug that allowed uninstalled games from platforms other than Steam to play the slot click animations when clicked.
- Fixed a bug that caused the overlay slot to show that unsupported games could be installed via the skin.
- Fixed a bug where game slots would not correctly replace unsupported characters when displaying a game's title because there is no banner to display.
- Fixed a bug where the title of the Filter window would not update correctly under certain circumstances.
- Fixed bugs that could cause division by zero when updating scrollbars.
- Optimized the file structure of `games.json` to reduce its file size and to improve the performance of tasks that require parsing said file.
- Switched to a new JSON library for improved performance.

**Version 3.0.4 - 2018/06/26:**
- Updated to support the new version of the Blizzard Battle.net launcher.
- Fixed a bug in the context menu option for opening the shortcuts folder.

**Version 3.0.3 - 2018/05/30:**
- Updated GOG Galaxy support to include arguments in the paths of games.

**Version 3.0.2 - 2018/05/30:**
- Updated to support the latest version of GOG Galaxy.

**Version 3.0.1 - 2018/05/26:**
- Fixed the manner in which arguments of Windows shortcuts are parsed.

**Version 3.0.0 - 2018/05/25:**
- Updated error messages related to version numbers of games, settings, and translations.
- Updated error messages to clarify that the preceding number is the line number in the Lua file where the error occurred rather than an error code.
- Fixed a bug where an uninstalled game's last played timestamp could be updated by attempting to start the game even though it should not be updated.
- Fixed a bug that caused the overlay slot background to be visible despite overlay slots being disabled.

**Version 3.0.0 beta 13 - 2018/05/22:**
- Fixed a bug where starting to install a Steam game via the skin would trigger bangs as if starting the game.
- Fixed a bug where installing a Steam game via the skin would not update its state from uninstalled to installed.

**Version 3.0.0 beta 12 - 2018/05/22:**
- Updated Steam platform to skip games with appmanifests that cause parsing errors and write the issue to the log.
- Updated Library class to improve how it deals with `games.json` having an unexpected structure.

**Version 3.0.0 beta 11 - 2018/05/20:**
- Updated the Library class to serialize the list of games in a sorted state.
- Updated the Main and Game configs to make use of serialized games being sorted.
- Updated the slot overlay and added a translation string to improve compatibility with some languages.
- Updated the Game config to have the tags sorted alphabetically in the preview.
- Refactored parts of the Game config.
- Fixed a bug in the Game config's slots when all of them cannot be filled.
- Fixed a bug that caused an error when manually executing stopping bangs while the skin is not monitoring a game process.
- Fixed a bug that caused newly created tags, which had been disabled, to become enabled when viewing the list of tags.
- Fixed a bug that caused unsaved changes, which had been made to one game, to be saved when another game was inspected via the Game config without closing the Game config first.

**Version 3.0.0 beta 10 - 2018/05/04:**
- Updated translations to improve compatibility with various languages.
- Updated Steam settings page to remove unsupported characters from the profile names of detected accounts.
- Fixed a bug in the GOG Galaxy platform related to downloading missing banners.

**Version 3.0.0 beta 9 - 2018/04/17:**
- Finished implementing games' ability to ignore executing bangs other than their own.
- Fixed a bug in the localization system that caused certain supported characters to be removed from strings.

**Version 3.0.0 beta 8 - 2018/04/16:**
- Fixed bugs caused by whitespace in paths processed by batch files.
- Fixed a bug that lead to multiple attempts to delete the cached Steam community profile.

**Version 3.0.0 beta 7 - 2018/04/12:**
- Updated readme to more accurately reflect the functionality of the search button.
- Updated the description of the `Parse community profile` setting in Steam's settings page.
- Fixed a bug that prevented the cached Steam community profile from being refreshed.
- Fixed a bug that crashed the skin when processing Windows shortcuts, if relevant paths included characters that are considered to be special characters in Lua patterns.

**Version 3.0.0 beta 6 - 2018/03/25:**
- Added more log messages to the Steam platform class.
- Updated the Game window to include a tooltip for game titles, which are long and might not fit in the title bar.
- Updated Game window layout.

**Version 3.0.0 beta 5 - 2018/03/08:**
- Added a slot overlay message for uninstalled games from platforms other than Steam and Blizzard Battle.net.
- Added tests for the Game class.
- Added tests for the Steam platform class.
- Added tests for the Blizzard Battle.net platform class.
- Added tests for the GOG Galaxy platform class.
- Added tests for the Windows shortcuts platform class.
- Added log messages to the methods in the Localization class.
- Updated the Valve Data Format parser.
- Updated setters in the Game class.
- Updated a log message in the Steam platform class.
- Updated how Steam libraries are detected in the Steam platform class.
- Updated how tags and last played timestamps are parsed in the Steam platform class.
- Updated shortcuts with invalid paths to be set as uninstalled in the Windows shortcuts platform class.
- Refactored code related to downloading and parsing community profiles in the Steam platform class.
- Refactored code related to validating e.g. values of settings in platform class constructors into their own validation methods to allow for tests.
- Refactored Blizzard Battle.net platform class to allow for tests.
- Refactored GOG Galaxy platform class to allow for tests.
- Refactored Windows shortcuts platform class to allow for tests.
- Fixed a bug related to saving translation files in the Localization class.
- Fixed a bug in the Steam platform class related to parsing the community profile.
- Fixed a bug that prevented use of localized strings in the 'Browse' button of settings related to folder paths.
- Fixed a default value for a localized string.
- Fixed a bug related to slot hover animations and games without banners.

**Version 3.0.0 beta 4 - 2018/02/26:**
- Added more checks to the various platforms to make sure that resources, titles, and paths are valid.
- Game class constructor now checks that titles are not empty strings.

**Version 3.0.0 beta 3 - 2018/02/25:**
- Fixed a bug, which was introduced in the previous version, in the setting types.

**Version 3.0.0 beta 2 - 2018/02/25:**
- Fixed a bug that caused an error when the number of slots in the .inc file is greater than the number of slots based on the settings.
- Game class constructor now checks if the platform ID is valid.
- Game class constructor now checks if a banner path was provided along with a banner URL.
- Added more assertions and updated old ones to help with debugging.
- Fixed a bug due to unexpected output when detecting Windows shortcuts.
- Fixed a bug due to unexpected output when detecting Steam games.
- Fixed a bug related to whitespace in paths to Steam libraries.

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
