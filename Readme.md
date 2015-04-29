Lauhdutin
==
A skin, which launches games, for Rainmeter.

<br>

#Contents
 - [Description](#description)
 - [How to install](#how-to-install)
 - [How to use](#how-to-use)
 - [User settings](#user-settings)
 - [Troubleshooting](#troubleshooting)
 - [License](#license)

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
Specify the absolute path to where you have Steam installed on your computer and your account's UserDataID in **UserSettings.inc** and refresh the skin. The skin should then automatically detect any games that have been installed via Steam.

###From other services or retail copies
**NOTE: The goal is to automate the process of adding games from services other than Steam so that one only needs to place a shortcut in a folder, but until then one of the methods described below are required.**

There are two ways to add non-Steam games:  
####1) By manually adding games to **Games.inc**.
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

####2) As a non-Steam game that is added to your Steam library.
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

##Excluding Steam games, DLC, movies, or applications
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

##Context menus
###Games
Opens **Games.inc** in Notepad.

###Steam shortcuts
Opens **SteamShortcuts.inc** in Notepad.

###Exceptions
Opens **Exceptions.inc** in Notepad.

<br>

#User settings
##SteamPath
The absolute path to the folder where Steam is installed.

```
SteamPath=C:\Program Files\Steam
```

##UserDataID
The UserDataID corresponding to your Steam account. This can be found by looking in the **userdata** folder found in the folder where you have Steam installed. There should be at least one folder in the **userdata** folder and the name of that folder is your UserDataID. If you have multiple folders in the **userdata** folder, then open up the **localconfig.vdf** file found in **\Steam\userdata\UserDataID\config\**. There should be a line containing **"PersonaName"** followed by the display name of the associated account. Look for the **localconfig.vdf** file that contains your account's display name.

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


##ToolbarBackgroundColor
The color and opacity of the toolbar's background (red, green, blue, opacity).

```
ToolbarBackgroundColor=0,0,0,191
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

JPG and PNG files are the default supported file types. If you want to use other file types, which are supported by Rainmeter, then you can add their extensions in the **Launcher.lua** file included in this skin. The line you are looking for is:
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
See [**License.md**](License.md) for more information.
