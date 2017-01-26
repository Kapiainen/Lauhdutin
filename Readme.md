***Development branch for version 2.0.0 prior to full release, which e.g. involves among other things implementing the back-end in Python.***

Lauhdutin
==
A Rainmeter skin for launching games.

![ex](demo.gif)

# Contents
 - [Requirements](#requirements)
 - [Installing](#installing)
 - [Changelog](#changelog)
 - [License](#license)

<<<<<<< HEAD
# Requirements
Developed with the following software in mind:
 - [Rainmeter 4.0 or later](https://www.rainmeter.net/)
 - [Python 3.5 or later](https://www.python.org/downloads/windows/) \*
 
 \* *The embeddable versions of Python do not include the **tkinter** module. The **Browse** buttons in the settings skin do nothing if the **tkinter** module is not present in the Python 3 environment. The rest of Lauhdutin should work just fine, but you will need to either add the **pythonw** executable to the PATH system variable or modify the **Python** variable found in **Settings.ini** and **Main.ini**.*

This skin may work with earlier Rainmeter and/or Python versions, but such configurations are not supported.

# Installing
- Install Rainmeter and Python 3 on your system (see [requirements](#requirements) for more info).
- Download a [release](https://github.com/Kapiainen/Lauhdutin/releases).
- Extract the **Lauhdutin** folder into your **\Rainmeter\Skins** folder.
- Load **Settings.ini**, adjust the various settings (e.g. path to Steam) to your liking, click the **Save** button, and finally click the **Exit** button.
- **Main.ini** should now load and will gather information on the games that you have installed. The skin will say **Processing...** for a while as it is e.g. downloading banners for games, but should eventually switch over to showing a list of games that it has found.
- Windows shortcuts (.lnk files) can be added to the **\Lauhdutin\@Resources\Shortcuts** folder.
- Banners for Windows shortcuts and Steam's Non-Steam game shortcuts can be added to the **\Lauhdutin\@Resources\Banners\Shortcuts** and **\Lauhdutin\@Resources\Banners\Steam shortcuts** folders, respectively. The name of the banner should match the name of the .lnk file or the name in Steam, respectively.

# Changelog
**Version 2.0.0 - YYYY/MM/DD:**
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
=======
<br>

#Description
This is a skin that was inspired by the Mini-Steam Launcher and [SteamRoller](https://github.com/CyrisXD/SteamRoller-Steam-Quick-Launcher). The goal is to offer a single launcher that can handle games that were purchased from various services.

The best level of integration is currently offered to games bought via Steam, but the goal is to offer similar or better support for games purchased from other services. Improving support for non-Steam games may require the development of a C++ or C# plugin in order to provide the Lua script with the necessary data. Alternatively the Lua script could be implemented in its entirety as a C++ or C# plugin.

<br>

#How to install
- Copy the **Lauhdutin** folder to **\Rainmeter\Skins**.
- (Re)start Rainmeter.
- Press the right-most button to open **UserSettings.inc** in Notepad.
- Adjust the settings to your liking (see the **User settings** section below for more information).
- Refresh the skin to apply the changes you've made to the settings.

<br>

#How to use
Hovering the mouse over the top edge of the skin shows a toolbar with three buttons:
- Search
- Sort
- User settings

##Searching
Left-clicking on the **Search** button opens the text input field. Entering nothing removes all filters and the skin will display all games. Right-clicking on the **Search** button also removes all filters and displays all games.

If you type in **bat**, then only games with the substring **bat** in their name will be shown.

Typing in **tags: role** will only show games with a tag containing the substring **role**. Multiple tags can be defined by separating the tags with a semicolon (**;**). For example **tags:role;shooter** would only show games that have one or more tags containing the substrings **role** and/or **shooter**.

Typing in **steam:false** will only show games that are not via Steam.

Prefacing any search term with a plus sign (**+**) will apply the search term to the current set of visible games. For example **tags:role** would show games with a tag containing the substring **role**, but adding **+dragon** would only show games with a tag containing the substring **role** as well as a name containing the substring **dragon**.

##Sorting
Left-clicking on the **Sort** button switches between the supported types of sorting:
- Alphabetically
- Most recently played

##Adding games
###From Steam
Specify the absolute [path to where you have Steam](#steampath) installed on your computer and your account's [UserDataID](#userdataid) in [**UserSettings.inc**](#user-settings), and then refresh the skin. The skin should then automatically detect any games that have been installed via Steam.

###From other services or retail copies
**NOTE: The goal is to automate the process of adding games from services other than Steam so that one only needs to place a shortcut in a folder, but until then one of the methods described below are required.**

There are three ways to add non-Steam games:  
####1) Via the *Add game* custom skin action.
Right-click somewhere on the skin and choose **Add game** from the **Custom skin actions** menu. A menu will open up where you can enter the following information by clicking on the corresponding button:  
- Name
- Path
- Tags
- Steam AppID

The **Name** and **Path** values are required. Multiple tags are separated by semicolons (**;**). If **Steam AppID** is defined, then the skin will attempt to download a banner for that *AppID*.

####2) By manually adding games to **Games.inc**.
Open **Games.inc**, which you can find in **\Rainmeter\Skins\Lauhdutin\@Resources**, with a text editor. The game entries should follow the format below:

```
"<INTEGER>"
{
    "path"    "<ABSOLUTE PATH TO EXECUTABLE>"
    "appid"   "<STEAM APPID OR NAME>"
    "name"    "<NAME>"
    "tags"
    {
        "<INTEGER>"   "<STRING>"
    }
}
```
For example:
```
"1"
{
		"path"		"H:\GOG Games\Shadowrun Returns\Shadowrun.exe"
		"appid"		"234650"
		"name"		"Shadowrun Returns"
		"tags"
		{
				"0"		"role-playing game"
		}
}
"2"
{
		"path"		"H:\GOG Games\Spelunky\Spelunky.exe"
		"name"		"Spelunky"
		"tags"
		{
				"0"		"rogue-like"
                "1"        "platformer"
		}
		"appid"		"239350"
}
```

Explanation of valid keys:  
**path**: The absolute path to an executable.  
**appid**: This is the name that is used to find the game's banner. If this is a valid Steam AppID, then it is used to automatically download a banner.  
**name**: The string that is used when sorting games alphabetically.  
**tags**: A set of tags associated with the game. (Optional)

####3) As a non-Steam game that is added to your Steam library.
Add a game as a non-Steam game to your Steam library, add it in whatever categories you want, and then refresh the skin. [Here](https://support.steampowered.com/kb_article.php?ref=2219-YDJV-5557) are instructions on how to add a non-Steam game to your Steam library.  

**NOTE: The Steam overlay will not work due to an inability to retrieve (in an automated fashion) the unique identifier that Steam generates for non-Steam games. A workaround is to:**  
**- create a desktop shortcut for the game via Steam**  
**- right-click on the shortcut and copy the URL**  
**- paste the URL in as the value corresponding to the *path* key in the game's entry in **Games.inc**

```
"3"
{
		"LastPlayed"		"1430247509"
		"name"		"Spelunky"
		"path"		"steam://rungameid/15780237864521957376"
}
```
If you don't want the game to show up when using the filter **steam:false**, then you can add **"Steam" "true"** to the game's entry as well:
```
"3"
{
		"LastPlayed"		"1430247509"
		"name"		"Spelunky"
		"path"		"steam://rungameid/15780237864521957376"
		"Steam"		"true"
}
```

##Banners
Banners are stored in **\Rainmeter\Skins\Lauhdutin\@Resources\Banners**. Games that have a valid Steam AppID will automatically download their banner from Steam, if a banner with a name that matches the AppID doesn't already exist.

Banners can be placed in the folder mentioned above. The file names of banners should match the value corresponding to the **appid** key. The name can be a valid Steam AppID or the name of the game for non-Steam games, depending on how you've added the game.

##Hiding Steam games, DLC, movies, or applications
If you want to stop certain games, DLC, movies, or applications from showing up in the launcher, then you have three options:
####1) Set the item in question as hidden in Steam.
####2) Double click the middle mouse button on the banner of the item in question in the skin.
####3) Add the AppID of the item in question and a name to the **Exceptions.inc** file.
The **Exceptions.inc** file can be found in the **@Resources** folder in the skin's folder, or opened by right-clicking on the skin and selecting the "Exceptions" option. The AppID of a Steam item can be found in the link of that item's Steam store page URL (store.steampowered.com/app/**AppID**).

```
"<STEAM APPID>"   "<NAME>"
```
For example:
```
"20930"		"The Witcher 2: Bonus Content"
```

Remove the line corresponding to the item in order reverse the exclusion.

##Hiding non-Steam games, applications, etc.
You have three options:
####1) Double click the middle mouse button on the banner of the game.

####2) Manually add the following line to a game's entry in *Games.inc*.

```
"hidden"    "true"
```

####3) Remove the game's entry in *Games.inc*.

The first two methods have the advantage of retaining the timestamp for when the game was last launched. If you used one of the first two methods and want to make the game visible again, then you can do one of two things:

####1) Open the *Add game* menu, type in the name of the game, and then click on *Add*.

####2) Manually edit *Game.inc* by removing the line containing the *"hidden"* key for the game and then refresh the skin.


##Custom skin actions
###Games
Opens **Games.inc** in Notepad.

###Steam shortcuts
Opens **SteamShortcuts.inc** in Notepad.

###Exceptions
Opens **Exceptions.inc** in Notepad.

###Add game
Open a menu where games can be added to the skin.

<br>

#User settings
User settings are stored in **UserSettings.inc**, which is stored in **\Rainmeter\Skins\Lauhdutin\@Resources**. This file can be opened by clicking on the gear icon, which is located in the skin's toolbar.

##SteamPath
The absolute path to the folder where Steam is installed.

```
SteamPath=E:\Steam
```

If the path contains whitespace (e.g. spaces), then the path needs to be enclosed in quotation marks.

```
SteamPath="C:\Program Files\Steam"
```

##UserDataID
The UserDataID corresponding to your Steam account. This can be found by looking in the **userdata** folder found in the folder where you have Steam installed. There should be at least one folder in the **userdata** folder and the name of that folder is your UserDataID. If you have multiple folders in the **userdata** folder, then open up the **localconfig.vdf** file found in **\Steam\userdata\UserDataID\config\**. There should be a line containing **"PersonaName"** followed by the display name of the associated account. Look for the **localconfig.vdf** file that contains your account's display name. You can also go to [steamid.io](https://steamid.io/lookup/) and do a profile search. Find steamID3 among the listing and copy the last set of numbers after the colon.
```
steamID3 [U:1:123456789]
```
```
UserDataID=123456789
```

##BannerWidth
The width of a banner in pixels.

```
BannerWidth=274
```

##BannerHeight
The height of a banner in pixels.

```
BannerHeight=128
```

##BannerOpacity
The opacity of a banner. 0 is invisible and 255 is opaque.

```
BannerOpacity=255
```

##SlotCount
The maximum number of games to show at once.

```
SlotCount=6
```

##Orientation
0 corresponds to a vertical layout (up to down) and 1 corresponds to a horizontal layout (left to right).

```
Orientation=0
```

##BackgroundColor
The color and opacity of the skin's background (red, green, blue, opacity).

```
BackgroundColor=0,0,0,128
```

##ToolbarLogoTint
The color and opacity of the logos in the toolbar (red, green, blue, opacity).

```
ToolbarLogoTint=255,255,255,255
```

##ToolbarBackgroundColor
The color and opacity of the toolbar's background (red, green, blue, opacity).

```
ToolbarBackgroundColor=0,0,0,191
```

##AddGameButtonColor
Color and opacity of the text on buttons in the menu where games can be added (red, green, blue, opacity).

```
AddGameButtonColor=0,0,0,255
```

##AddGameButtonBackgroundColor
Color and opacity of the buttons in the menu where games can be added.

```
AddGameButtonBackgroundColor=127,127,127,255
```

##RefreshInterval
The interval between when the skin checks for new games. The unit is seconds.

```
RefreshInterval=-1
```

##HideMessages
Error messages are hidden if set to 1.

```
HideMessages=0
```

##ScrollMultiplier
The amount of games to scroll by when scrolling the mouse wheel.

```
ScrollMultiplier=1
```

<br>

#Troubleshooting
##Error messages
###"Missing banner *NAME OF FILE* for *NAME OF GAME*"
A game is missing a banner. This issue can be resolved by acquiring a banner for the game and placing it in the **Banner** folder found in the skin's **@Resources** folder. If **NAME OF FILE** is a valid Steam AppID, then the skin will attempt to download a banner. Otherwise you will have to supply the skin with a banner with a filename matching **NAME OF FILE**.

JPG and PNG files are the default supported file types. If you want to use other file types, which are supported by Rainmeter, then you can add their extensions in the **Lauhdutin.lua** file included in this skin. The line you are looking for is:
```
T_SUPPORTED_BANNER_EXTENSIONS = {'.jpg', '.png'}
```
You can add more file types by adding more entries to the table. For example:
```
T_SUPPORTED_BANNER_EXTENSIONS = {'.jpg', '.png', '.bmp', '.ico'}
```

###"Missing Steam UserDataID or invalid Steam path"
The skin is unable to find the necessary files that should exist within a typical Steam folder. Either the path, which has been specified in **UserSettings.inc**, to Steam is incorrect or the UserDataID has not been defined at all.

###"Invalid Steam UserDataID and/or Steam path"
The skin is unable to find the necessary files that should exist within a typical Steam folder. Either the path, which has been specified in **UserSettings.inc**, to Steam is incorrect or the UserDataID is incorrect.

##Some or all of my Steam games are not showing up
Right-click on the skin and left-click on the "Exceptions" option. An instance of Notepad should start and open a file called **Exceptions.inc**. If this file contains lines containing the names of games, which you haven't manually added to the list by editing the file directly or by middle-mouse clicking the banner of a game purchased via Steam, then the listed game(s) may have been added to the file because the skin was unable to download the banner. The skin may fail to download a banner if for example there is no banner for the particular game, DLC, or application. Another possible cause would be a lack of access to the internet. If you want the skin to perform another attempt at downloading banners for games listed in the **Exceptions.inc** file, then all you need to do is remove the lines that correspond to the games you want to download banners for, save the file, and refresh the skin.

<br>

#License
>>>>>>> refs/remotes/origin/master
See [**License.md**](License.md) for more information.

This software makes use of [json4lua](https://github.com/craigmj/json4lua) ([license](./Lauhdutin/@Resources/Dependencies/json4lua/LICENCE.txt)).