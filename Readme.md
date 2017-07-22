Lauhdutin
==
A Rainmeter skin for aggregating games from different platforms and then launching them. Supports Steam, GOG Galaxy, Blizzard App, and regular Windows shortcuts. Games are presented as a scrollable list that can be filtered and sorted in multiple ways. There are a variety of settings that allow you to customize the appearance of the skin (e.g. orientation, number of slots, dimensions of a slot, animations). This skin can also be used as a general purpose launcher since it supports regular Windows shortcuts.

![ex](Docs/demo.gif)

[Higher resolution version of the animated GIF](Docs/Demo-original.gif)

# Contents
 - [Requirements](#requirements)
 - [Installing](#installing)
 - [Updating](#updating)
 - [Features](#features)
   - [Supported platforms](#supported-platforms)
   - [Filtering](#filtering)
   - [Sorting](#sorting)
   - [Bangs](#bangs)
   - [Notes](#notes)
   - [Manual process override](#manual-process-override)
   - [Highlighting](#highlighting)
   - [Animations](#animations)
 - [Reporting issues](#reporting-issues)
 - [Contributing](#contributing)
 - [Changelog](#changelog)
 - [License](#license)

# Requirements
Developed with the following software in mind:
 - [Rainmeter 4.0 or later](https://www.rainmeter.net/)
 - [Python 3.5 or later](https://www.python.org/downloads/windows/) \*
 
 \* Tick the checkbox on the first screen of the Python installer to add Python to the PATH system variable and make sure that **tkinter** is ticked in the section for optional features. The embeddable versions of Python do not include the **tkinter** module. The **Browse** buttons in the settings skin do nothing if the **tkinter** module is not present in the Python 3 environment. The rest of Lauhdutin should work just fine, but you will need to specify the absolute path to the **pythonw** executable in the settings menu. If you have multiple versions of Python installed (e.g. 2.7 and 3.5), then you may have to specify the absolute path to the **pythonw** executable for 3.5 in the settings menu if the system defaults to 2.7.

# Installing
- Install Rainmeter and Python 3 on your system (see [requirements](#requirements) for more info).
  - [Add Python to the PATH system variable](Docs/PythonStep1.jpg).
  - [Customize the installation](Docs/PythonStep1.jpg).
  - [Install the `tcl/tk and IDLE` optional feature.](Docs/PythonStep2.jpg)
- Download a [release](https://github.com/Kapiainen/Lauhdutin/releases).
- Extract the **Lauhdutin** folder and place it in `\Rainmeter\Skins`.
- Load **Settings.ini**, adjust the various settings (e.g. path to Steam) to your liking (hover over the title of a setting for more information about the setting), click the **Save** button, and finally click the **Exit** button.
- **Main.ini** should now load and will gather information on the games that you have installed. The skin will say `Processing...` for a while. At some point the skin should say `Downloading...` as it is e.g. downloading banners for games, but should eventually switch over to showing a list of games that have been found.
- Windows shortcuts (.lnk and .url files) can be added to the `\Lauhdutin\@Resources\Shortcuts` folder.
- Banners for Windows shortcuts and Steam's Non-Steam game shortcuts can be added to the `\Lauhdutin\@Resources\Banners\Shortcuts` and `\Lauhdutin\@Resources\Banners\Steam shortcuts` folders, respectively. The name of the banner should match the name of the .lnk or .url file, or the name in Steam, respectively.

# Updating
If you are using an older version of Lauhdutin (2.0.0 or newer) and want to update to the latest version, then you have two recommended options:

- Remove the old version completely from `\Rainmeter\Skins` and then proceed with the [normal installation steps](#installing).
- Caution! You will lose:
  - All information regarding total time played that was tracked solely by **Lauhdutin**. Steam tracks this information independently for its games.
  - All settings (e.g. layout, Steam UserDataID, hidden games).

or

- Remove all files from `\Rainmeter\Skins\Lauhdutin` except for the following files and folders:
```
\Rainmeter\Skins\Lauhdutin\@Resources\games.json
\Rainmeter\Skins\Lauhdutin\@Resources\settings.json
\Rainmeter\Skins\Lauhdutin\@Resources\Banners
\Rainmeter\Skins\Lauhdutin\@Resources\Shortcuts
```
- If you are using a Python path that differs from the default value, then do not remove `\Rainmeter\Skins\Lauhdutin\@Resources\PythonPath.inc` either!
- If you are using custom icons (not referring to game banners), then do not remove `\Rainmeter\Skins\Lauhdutin\@Resources\Icons` either!
- Extract the latest version of Lauhdutin over the old version's remaining barebones folder. Do not overwrite `PythonPath.inc`, if you left it intact when removing files and folders. Do not overwrite any custom icons you may have been using either, if you were using custom icons for e.g. showing how games are being sorted.
- Load **Settings.ini** in Rainmeter, click **Save**, click **Exit**, right-click on the skin, go to **Custom skin actions**, and click on **Rebuild skin**.

# Features

## Supported platforms

### Steam
Support includes:
- Acquire a list of installed games and games that are not currently installed, but for which a license has been purchased.
- Acquire a list of games that have been added to Steam as a 'non-Steam game'.
- Launch the games that were found by the features described above.
- Install Steam games that are not currently installed.
- Automatically copy custom grid images assigned in Steam as banners.
- Automatically download banners for Steam games that were found.
- Integrate the total amount of hours played that is tracked by Steam into Lauhdutin's corresponding system.

### GOG Galaxy
Support includes:
- Acquire a list of games installed via GOG Galaxy.
- Launch games that were found.
- Automatically download banners for games that were found.

### Blizzard App
Support includes:
- Acquire a list of games installed via Blizzard App.
- Launch games that were found.
- Automatically download banners for games that were found.

Blizzard App support does not include support for classic games (e.g. Diablo II, Warcraft III).

### Other platforms

Additional platforms may receive similar support in the future, if possible. In the mean time it is possible to add games, which were not installed via the supported platforms described above, by placing a shortcut in `\Rainmeter\Skins\Lauhdutin\@Resources\Shortcuts` (banners can be placed in `\Rainmeter\Skins\Lauhdutin\@Resources\Banners\Shortcuts` with the same name as the shortcut).

## Filtering
The list of games can be narrowed down by applying a filter. Filters can be applied by left-clicking on the magnifying glass in the toolbar, which becomes visible when you nudge the top of the skin. Filters can be removed by either right-clicking on the magnifying glass or by applying a blank filter.

- `<search string>`

  Replace `<search string>` with whatever would be a (partial) match with a game's name. If fuzzy search is enabled, then games will be ranked based on multiple factors (e.g. how many characters in `<search string>` match characters in a game's name, if characters in `<search string>` match the first letter of words in a game's name).

- `<platform>:<argument>`

  Replace `<platform>` with one of the supported platforms:

  - `steam` = [Steam](http://store.steampowered.com/)
  - `galaxy` = [GOG Galaxy](https://www.gog.com/galaxy)
  - `blizzard` = [Blizzard App](http://eu.battle.net/en/)

  Replace `<argument>` with one of the supported arguments:

  - `all` = Show both installed and uninstalled games that are available via the platform.
  - `false` = Show all other games that were not installed via the platform.
  - `installed` = Show games installed via the platform.
  - `uninstalled` = Show games that are available via the platform, but not installed.
  - `played` = Show games that are available via the platform and have a total played time above 0 hours.
  - `not played` = Show games that are available via the platform and have a total played time equal to 0 hours.

  All arguments might not work with all platforms.

- `installed:<argument>`

  Replace `<argument>` with one of the supported arguments:

  - `true` = Show installed games.
  - `false` = Show games that are not installed (only Steam games are supported at the moment).

- `hidden:<argument>`

  Replace `<argument>` with one of the supported arguments:
  
  - `true` = Show only games that are hidden.
  - `false` = Show only games that are not hidden.

- `games:all`

  Show all games regardless of whether or not the game is installed, uninstalled, or hidden.

- `played:<argument>`

  Replace `<argument>` with one of the supported arguments:

  - `true` = Show games with a total played time above 0 hours.
  - `false` = Show games with a total played time equal to 0 hours.

- `shortcuts:<argument>`

  Replace `<argument>` with the (partial) name of a folder in `\Lauhdutin\@Resources\Shortcuts` to show the shortcuts in that folder.

- `tags:<argument>`

  Replace `<argument>` with a (partial) match to a tag that is assigned to a game. Tags can be assigned by middle-mouse clicking on a slot that contains a game, clicking on the button labeled *Tags*, and editing the text file that is opened in Notepad (one tag per line). Tags/categories assigned in Steam are also supported.

- `random:<argument>`

  Replace `<argument>` with one of the supported arguments:

  - `all` = Show one random game.
  - `played` = Show one random game that has a total played time above 0 hours.
  - `not played` = Show one random game that has a total played time equal to 0 hours.
  - `steam` = Show one random game from Steam.
  - `galaxy` = Show one random game from GOG Galaxy.
  - `blizzard` = Show one random game from Blizzard App.
  
  If no argument is provided, then one random game from the current list of games is shown.

- `+<filter>`

  Replace `<filter>` with one of the filters described above to further filter the current set of filtered games.

Games that are not currently installed or are set as hidden are not shown by default when filtering, unless stated otherwise. There are settings for making each category of aforementioned games show up when filtering.

## Sorting
The icon in the middle of the toolbar shows and controls the sorting mode. Left-clicking on this icon will cycle through the different sorting modes (alphabetically, most recently played, and total hours played). Right-clicking on this icon will reverse the order of the current list of sorted games.

## Bangs
There are settings for executing [bangs](https://docs.rainmeter.net/manual/bangs/) under specific circumstances. Multiple bangs can be executed by enclosing each bang in square brackets: 

```[!ActivateConfig "SomeConfigName"][!Log "Starting a game"]```

Multiple bangs can also be written on multiple lines:

```
[!ActivateConfig "SomeConfigName"]
[!Log "Starting a game"]
```

This feature can be used to e.g. load and unload skins.

Currently supported events that can be used to trigger the execution of bangs:
- A game starts running. Works with any installed game that is listed in Lauhdutin.
- A game stops running. Works with any:
  - Steam game, provided that the Steam in-game overlay setting is enabled in Steam.
  - non-Steam game that has a process that can be tracked (i.e. Lauhdutin is capable of keeping track of how many hours have been spent playing the game).

The stopping bang can also be executed manually via the context menu, if the skin fails to automatically execute it when a game stops running.

Games can be excempted from executing bangs by middle-mouse clicking on the slot that contains the game and then clicking on the button labeled *Bangs*.

## Notes
Notes can be added to a game by middle-mouse clicking on a slot that contains a game, clicking on the button labeled *Notes*, and editing the text file that is opened in Notepad.

## Manual process override
In some circumstances it may be necessary or desirable to monitor a process other than the default one (e.g. Steam Overlay in the case of Steam games). This can be done by middle-mouse clicking on a slot that contains a game, clicking on the button labeled *Process*, and typing in the name of the process in the input field that is opened at the top of the skin. Inputting a blank value will remove the override. Process names can be found in the Windows Task Manager (<kbd>CTRL</kbd>+<kbd>SHIFT</kbd>+<kbd>ESC</kbd>).

## Highlighting

If highlighting is enabled, then additional contextual information can be shown when the mouse cursor is hovered over a slot ([animated example](Docs/Highlighting.gif)). There are some settings for toggling certain pieces of information (e.g. platform, hours played).

## Animations

### Clicking
One of these animations can be played when a slot is left-clicked ([animated example](Docs/ClickAnimations.gif)):

- Shift left
- Shift up
- Shift right
- Shift down
- Shrink

Click animations can be disabled completely.

### Hovering
One of these animations can be played when the mouse cursor hovers over a slot ([animated example](Docs/HoverAnimations.gif)): 

- Zoom in
- Jiggle
- Shake

Hover animations can be disabled completely.

### Skin
The entire skin can be made to slide into and out of view when placed along an edge of a monitor ([animated example](Docs/SkinAnimation.gif)). There is a setting that can be used to determine which direction the skin slides into and out of view. A 1 px wide/tall invisible sliver is placed along the corresponding edge of the skin when this feature is enabled and hovering the mouse cursor on this sliver makes the skin slide into view.

Skin animations can be disabled completely.

# Reporting issues
If you encounter an issue while trying to use Lauhdutin, then please read through the readme in case there is an explanation on how to deal with the issue.

If the issue persists, then check through the repository's [Issues](https://github.com/Kapiainen/Lauhdutin/issues) section for open or closed issues that might be relevant and post there (or reference that issue when contacting outside of GitHub).

If there is no previously submitted issue that matches your issue, then submit an issue report based on this [template](https://github.com/Kapiainen/Lauhdutin/blob/master/.github/ISSUE_TEMPLATE.md) (check the raw version for comments with more detailed steps).

# Contributing

Fork [this](https://github.com/Kapiainen/Lauhdutin) repository (preferrably the `development` branch), make your changes, and submit a pull request to the `development` branch with a summary of the changes you've made.

Try to include tests and mock data for those tests. These tests should preferrably be integrated into the build system that is used to generate releases.

Try to keep the number of dependencies, which cannot be included in the skin or are not a part of a default Windows installation, to a minimum.

[List of contributors](Contributors.md)

## Graphical user interface changes
Try to keep draw calls to a minimum by, for example:
- Not overriding the skin-wide `DefaultUpdateDivider=-1` option.
- Executing the `!Redraw` bang only when necessary (e.g. update all meter options prior to a draw call instead of setting a few options, drawing, and then setting the rest of the options).

## Adding support for a platform
There are a few rules that **must** be followed when adding support for additional platforms:
- Sensitive account data must never be transmitted from the user's system.
- All data that is retrieved and/or utilized by the skin must have been intentionally made publicly available by the platform's developers and/or stored locally in an unencrypted state.
- Local data should be preferred over data that needs to be acquired over the internet.
- Minimize internet usage by e.g. downloading a banner only if a local copy does not already exist.

Any deviations from the rules regarding adding platform support will most likely result in a rejected pull request.

# Changelog
**Version 2.8.0 - 2017/MM/DD:**
- Added daily backups of *games.json*.
- Added z-position adjustment when editing a game's process name.
- Added more status messages when initializing the skin.
- Updated the status messages for downloading banners to include the progress in percent.
- Updated the debug status message for the number of banners to download to include Blizzard games.
- Updated Steam support with more error messages.
- Implemented a workaround for displaying exception messages with single quotation marks.
- Fixed a bug that caused a thin black outline around slots when a hover animation was played. Requires that the skin is rebuilt for the change to take effect.

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


# License
See [**License.md**](License.md) for more information.

This software makes use of [json4lua](https://github.com/craigmj/json4lua) ([license](./Lauhdutin/@Resources/Dependencies/json4lua/LICENCE.txt)).
