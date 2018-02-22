Lauhdutin
==
A Rainmeter skin for aggregating games from different platforms and launching them. Supports Steam, GOG Galaxy, Blizzard Battle.net, and regular Windows shortcuts. Games are presented as a scrollable list that can be filtered and sorted in multiple ways. There are a variety of settings that allow you to customize the appearance of the skin (e.g. orientation, number of slots, dimensions of slots, animations). This skin can also be used as a general purpose launcher since it supports regular Windows shortcuts.

![example](https://github.com/Kapiainen/Lauhdutin/wiki/images/image-main-window.jpg)

# Contents
 - [Requirements](#requirements)
 - [Installing](#installing)
 - [Updating](#updating)
 - [Features](#features)
   - [Supported platforms](#supported-platforms)
   - [Games](#games)
   - [Banners](#banners)
   - [Searching](#searching)
   - [Sorting](#sorting)
   - [Filtering](#filtering)
   - [Bangs](#bangs)
   - [Context actions](#context-actions)
   - [Animations](#animations)
   - [Localization](#localization)
 - [Reporting issues](#reporting-issues)
 - [Contributing](#contributing)
 - [Changelog](#changelog)
 - [License](#license)

# Requirements
 - [Rainmeter 4.0 or later](https://www.rainmeter.net/)
 - Windows Script Host 5.8 or later
   - Should be included by default in all versions of Windows that are supported by Rainmeter 4.0 and later.

# Installing
- Install Rainmeter, if you do not already have it.
- Download a [release](https://github.com/Kapiainen/Lauhdutin/releases).
- Extract the contents of the release archive to `\Rainmeter\Skins\Lauhdutin`.
- Load **Settings.ini**, adjust the various settings (e.g. path to Steam) to your liking (hover over the title of a setting for more information about the setting), click the **Save** button, and finally click the **Close** button.
- Load **Main.ini**, which should now detect games based on your settings.
- Windows shortcuts (.lnk and .url files) can be added to the `\Lauhdutin\@Resources\Shortcuts` folder. This folder can also be opened via a context option in the main config or via the settings page for Windows shortcuts.

# Updating
## 2.x.x to 3.x.x

If you are using the previous major version (2.x.x) of Lauhdutin, then you may be able to migrate your settings and/or games to the new major version (3.x.x). Settings and games from version 2.7.1 should be possible to migrate with a minimal amount of issues though some may arise from e.g. changes in the folder structure.

Copy `games.json` and `settings.json` from the `@Resources` folder of the old version of Lauhdutin and paste them in the `@Resources` folder of the new version of Lauhdutin. Load **Main.ini**.

## 3.x.x

The various files that store e.g. settings or games now include a version number that is used to implement the migration of files between versions, which should allow for major changes in the structures of such files without loss of data.

# Features

## Supported platforms

### Steam

Support includes:
- Acquire a list of installed games and games that are not currently installed, but for which a license has been purchased.
- Acquire a list of games that have been added to Steam as a 'non-Steam game'.
- Launch games that were found by the previous points.
- Install Steam games that are not currently installed.
- Automatically copy custom grid images assigned in Steam as banners.
- Automatically download banners for Steam games that were found.
- Integrate the total amount of hours played and last played timestamp, which are tracked for each game by Steam into Lauhdutin's corresponding system.

### GOG Galaxy

Support includes:
- Acquire a list of games installed via GOG Galaxy.
- Launch games directly via the game's executable or via the GOG Galaxy client.
- Automatically download banners for games that were found.

**NOTE:** GOG Galaxy support requires placing the command-line tool `sqlite3.exe`, which can be downloaded [here](http://www.sqlite.org/download.html) as part of the `sqlite-tools-win*.zip` archive, in Lauhdutin's `@Resources` folder.

### Blizzard Battle.net

Support includes:
- Acquire a list of games installed via Blizzard Battle.net.
- Launch games via the Blizzard Battle.net client.

Blizzard Battle.net support does not currently include support for classic games (e.g. Diablo II, Warcraft III).

### Other platforms

Additional platforms may receive similar support in the future, if possible. In the mean time it is possible to add games, which were not installed via the supported platforms described above, by placing a shortcut in `\@Resources\Shortcuts`. Banners should be placed in the same folder with the same name as the shortcut (e.g. `SomeGame.lnk` and `SomeGame.jpg`).

## Context menu actions

### Settings

Show the settings window. If a setting is modified, then the main skin will be refreshed automatically. Any changes that affect the layout of the main skin in any way will also trigger the main skin to be refreshed after the skin has been rebuilt according to the new settings.

### Open shortcuts folder

Open the folder where Windows shortcuts and their banners should be placed.

### Execute stopping bangs

Stop monitoring the game and execute bangs, if they are enabled and any bangs are defined. This can be used if the skin fails to detect that a game is no longer running or if the game was never started.

### Start/stop hiding/unhiding/removing games

These context actions change what left-clicking on a game does. This can be used to hide/unhide/remove multiple games quickly without having to go through the Game window (see [Games](#games)) for each individual game.

## Games

Games are presented in slots, which can be interacted with. Slots can have an overlay, which is shown when the mouse is hovered over the slot, to show context-sensitive information (e.g. if the game's platform is running, the action that will be taken when left-clicked).

- Left-clicking a slot launches the game shown in the slot. Can be configured to require double-clicking.
- Middle-clicking a slot shows details about the game in a separate window.

![example](https://github.com/Kapiainen/Lauhdutin/wiki/images/image-game-window.jpg)

The window for game details (see above) can be used to view various details about the game. Platforms with a `*` next to them usually indicates a platform override as described in the [Other platforms](#other-platforms) sub-section of the [Supported platforms](#supported-platforms) section. Non-Steam game shortcuts, which also use a platform override to indicate that the game itself is not actually a native Steam game and as such may have comparatively limited support, are the exception to this rule.

Some details can also be modified:

- Toggle the visibility of the game.
- Modify the process to monitor to determine whether or not a game is running. A blank string reverts to the default process. A `*` next to the process indicates that the value has been modified.
- Keep notes.
- Assign tags for filtering purposes. Some tags may have been assigned via the game's platform, which is indicated by a `*`, and cannot be altered via Lauhdutin.
- Set the game to ignore global and platform-specific bangs.
- Assign starting and/or stopping bangs.

# Banners

Banners for **Windows shortcuts** can be added to the same folder as the shortcuts and must have the same name as the corresponding shortcut (e.g. `Spelunky.jpg` if the shortcut is called `Spelunky.lnk`).

Custom banners for other platforms can be placed in `\Rainmeter\Skins\Lauhdutin\@Resources\cache\<platform name here>`. If there is no existing banner to replace, then the name to use for the banner will depend on the platform:
- **Steam**: Use the game's AppID, which can e.g. be found in the URL of the game's Steam store page. The AppID can also be found by inspecting the game's path in the Game window (see [Games](#games)).
- **Steam (shortcuts for non-Steam games)**: Use the ID is generated based on the path to the game's executable and its name in your Steam library. The ID can also be found by inspecting the game's path in the Game window (see [Games](#games)).
- **Blizzard Battle.net**: Use the name of the game's folder (e.g. `Hearthstone.jpg` if the game's folder is called `Hearthstone`).
- **GOG Galaxy**: Use the game's ID, which can be found by inspecting the game's path in the Game window (see [Games](#games)) when launching GOG Galaxy games via the client.

If the skin fails to download a banner for a game from a platform that supports automatic downloading of banners, then a file with the extension `.failedToDownload` can be found instead where the banner should be. Removing this file will cause the skin to make another attempt to download the banner the next time that the skin is refreshed.

## Searching

![example](https://github.com/Kapiainen/Lauhdutin/wiki/images/image-search-window.jpg)

The button on the left-hand side of the toolbar is for searching for games based on the title. Searching uses fuzzy matching, which means that you do not need to input the exact same title as the game you are looking for. Titles are instead compared to the input and given a score. Using just the initials of a game's title should be enough to place it at the top of the list of results in many cases (e.g. `wtno` for `Wolfenstein: The New Order`).

- Left-clicking the button searches all games.
- Middle-clicking the button searches the current set of games, which might be the result of applying various filters.
- Right-clicking the button clears all filters and resets the list of games.

## Sorting

![example](https://github.com/Kapiainen/Lauhdutin/wiki/images/image-sort-window.jpg)

The button in the middle of the toolbar shows and controls the sorting mode.

- Left-clicking this button brings up a window where you can select the sorting mode.
- Middle-clicking the button cycles through the different sorting modes.
- Right-clicking the button will reverse the order of the current list of sorted games.

## Filtering

![example](https://github.com/Kapiainen/Lauhdutin/wiki/images/image-filter-window.jpg)

The list of games can be narrowed down by applying a filter. Filters can be applied by clicking on the filter button, which is on the right-hand side of the toolbar.

- Left-clicking the button will apply the filter to all games.
- Middle-clicking the button will apply the filter to the current set of games and can be used to further narrow down the set of games by applying multiple filters.
- Right-clicking the button is a shortcut for clearing all filters.

A new window with a list of filters will show up and you can choose the filter to apply.

Games that are not currently installed or are set as hidden are not shown by default when filtering. Such games can be shown by applying a filter to show hidden or uninstalled games, and then those games can be filtered by applying filters via middle-clicking on the filter button.

## Bangs
There are settings for executing [bangs](https://docs.rainmeter.net/manual/bangs/) under specific circumstances. Multiple bangs can be executed by enclosing each bang in square brackets: 

```
[!ActivateConfig "SomeConfigName"][!Log "Starting a game"]
```

Multiple bangs can also be written on multiple lines:

```
[!ActivateConfig "SomeConfigName"]
[!Log "Starting a game"]
```

This feature can be used to e.g. load and unload skins.

Currently supported events that can be used to trigger the execution of bangs:
- Any game is started or stopped.
- Any game *from a specific platform* is started or stopped.
- A specific game is started or stopped.

The stopping bang can also be executed manually via the context menu, if the skin fails to automatically execute it when a game stops running or if a game fails to start at all.

Games can be excempted from executing global and platform-specific bangs via the game window (see [Games](#games)).

## Animations

### Clicking a slot
One of these animations can be played when a slot is left-clicked:

- Shift left
- Shift up
- Shift right
- Shift down
- Shrink

Click animations can be disabled completely.

### Hovering over a slot
One of these animations can be played when the mouse cursor hovers over a slot:

- Zoom in
- Jiggle
- Shake left and right
- Shake up and down

Hover animations can be disabled completely.

### Skin
The entire skin can be made to slide into and out of view when placed along an edge of a monitor. There is a setting that can be used to determine which direction the skin slides into and out of view. A 1 px wide/tall invisible sliver is placed along the corresponding edge of the skin when this feature is enabled and hovering the mouse cursor on this sliver makes the skin slide into view.

A delay can also be added to triggering the animation that reveals the skin. This should help minimize accidentally launching a game.

Skin animations can be disabled completely.

# Localization

This skin supports localization, though it is somewhat limited. The default language is English, but additional languages can be added by copying `English.txt`, which can be found in `@Resources\Languages`, and translating the strings. The name of the file is the name of the language in the settings window. The first line of the file should be the version of the localization system:

```
version N
```

Subsequent lines are the keys and values separated by a tab character:

```
key value
```

The localization system makes use of Lua's string formatting capabilities to insert values from variables (e.g. game title, hours played).

Newlines must be escaped, i.e. `\n`, if a translation is supposed to span multiple lines.

Some characters might not be supported and will simply be omitted by the skin. The currently supported character sets should be enough for many languages, which use the Latin alphabet. If you encounter issues with some characters, then please create an issue on the GitHub repo. Additional character sets can hopefully be supported in the future, but Unicode support seems to be limited due to the Lua 5.1 runtime environment.

Only the English translation file is included in each release archive. Additional translation files can be submitted afterwards. Updated translation files, or up-to-date translation files from a previous release, will be added to the release as optional downloads.

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
- Not overriding the skin-wide `DefaultUpdateDivider=-1` option, if possible.
- Executing the `!Redraw` bang only when necessary (e.g. update all meter options prior to a draw call instead of setting a few options, drawing, setting the rest of the options, and drawing again).

## Adding support for a platform
There are a few rules that **must** be followed when adding support for additional platforms:
- Sensitive account data must never be transmitted from the user's system.
- All data that is retrieved and/or utilized by the skin must have been intentionally made publicly available by the platform's developers and/or stored locally in an unencrypted state.
- Local data should be preferred over data that needs to be acquired over the internet.
- Minimize internet usage by e.g. downloading a banner only if a local copy does not already exist.

Any deviations from the rules regarding adding platform support will most likely result in a rejected pull request.

# Changelog

**Version 3.0.0 - 2018/MM/DD:**
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


# License
See [**License.md**](License.md) for more information.

This software makes use of:
- [json4lua](https://github.com/craigmj/json4lua) by Craig Mason-Jones (MIT license)
- [digest.crc32](https://github.com/davidm/lua-digest-crc32lua) by David Manura (MIT license)
- [bit.numberlua](https://github.com/davidm/lua-bit-numberlua) by David Manura (MIT license)
- Rainmeter helpers by Kapiainen (MIT license)
