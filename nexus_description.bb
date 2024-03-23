[size=5][b]Overview[/b][/size]
[b]Preemptively Label Containers aims to streamline looting by automatically labeling empty containers/corpses before you open them[/b], while also being able to filter out items read from a JSON file (e.g.: rotten food, miscellaneous items with no particular use, etc). You can also label containers with the number of items inside if they're not empty, establish a DC for a perception check to determine whether a container should be labeled, configure various label options, etc.

[b]The mod works out of the box, defaulting to appending '(Empty)' to the name of all nearby empty containers[/b]. Also, common 'useless' items won't be counted. See the settings breakdown in the Configuration section below for more details.

[img]https://i.imgur.com/B18jPWk.gif[/img]

[b]By design, it does NOT save any of the labels or other info to your save. Instead, it dynamically updates container names by scanning for nearby containers on a timer[/b]. This approach should be more efficient than the constant monitoring used by aura mods. Therefore, upon loading a save, container names return to their original state (they will be instantly updated again if the mod is enabled), as no changes are recorded to your .loca files. This enables an easier uninstallation  and avoids problems associated with lost references to string handles.

Players that use [s]German[/s], Polish, Russian, Simplified Chinese, Turkish, Traditional Chinese, Ukrainian, Korean, or Japanese translations: please let me know in the Posts tab if the mod works at all, if the label makes sense in your language, and what you would suggest as an alternative (I don't know if I can do anything about it though, but I can consider it). Also, note that some options detailed below might not work for non-Latin characters. Thanks!

[line][b][size=5][b]
Installation[/b][/size][/b]
[list=1]
[*]Download the .zip file and install using BG3MM (recommended); Vortex is not recommended.

[/list][b][size=4]Requirements
[/size][/b][size=2][url=https://www.nexusmods.com/baldursgate3/mods/141]Mod Fixer[/url]﻿
[url=https://github.com/Norbyte/bg3se]BG3 Script Extender[/url] [size=2](you can easily install it with BG3MM through its [i]Tools[/i] tab or by pressing CTRL+SHIFT+ALT+T while its window is focused)
[line]
[/size][/size][size=5][b]Configuration[/b][/size][size=2][size=2]
When you load a save with the mod for the first time, it will automatically create a [font=Courier New]preemptively_label_containers_config.json[/font] file with default options.

You can easily navigate to it on Windows by pressing WIN+R and entering [/size][/size]
[size=2][size=2][quote][code]explorer %LocalAppData%\Larian Studios\Baldur's Gate 3\Script Extender\PreemptivelyLabelContainers
[/code][/quote]
Open the JSON file with any text editor, even regular Notepad will work. Here's what each option inside does (order doesn't matter):
[/size][/size][size=2][size=2]
[size=2][size=2][font=Courier New]"GENERAL"[/font]:[/size]
[font=Courier New]   ﻿"enabled"[/font]: Set to true to enable the mod, false to disable it without uninstalling. [size=2]Enabled by default.[/size]

[size=2][font=Courier New]"FEATURES"[/font]: Defines various operational parameters of the mod.[/size]
[font=Courier New]   ﻿"radius": [/font]Specifies how far (in meters) the mod searches for nearby containers. [size=2]Default is 10 meters. The controller search radius is  5.[/size]
[font=Courier New]   ﻿"refresh_interval": [/font]Determines how often (in milliseconds) the list of nearby containers is refreshed. [size=2]Default is 500ms. Set it between 200-2000ms based on your CPU power.[/size]
        [font=Courier New]"also_check_for_party_members": [/font]Considers distant party members when searching for containers if [font=Courier New]true[/font]. Useful for multiplayer sessions. Enabled by default.

[font=Courier New]   ﻿"labeling"[/font]: Configuration for the labeling of containers.
   ﻿    - [font=Courier New]"owned_containers"   [/font]: If [font=Courier New]true[/font], labels containers owned by others (containers/corpses having red highlight). [size=2]Enabled by default.[/size]
   ﻿    - [font=Courier New]"perception_check_dc"[/font]: Sets the difficulty for a 'fake' perception check to label a container. [size=2]0 means always successful. Default is [font=Courier New]0[/font].[/size]
[size=2][size=2][size=2]                  [size=2][size=2][size=2]-[/size][/size][/size] [/size][/size][/size][size=2][size=2][size=2][size=2][size=2][size=2][font=Courier New] "always_relabel"[/font][/size][/size][/size][/size][/size][/size][/size][/size][/size][size=2][size=2][size=2][size=2][size=2][size=2][size=2][size=2][size=2]: Always update labels, even if containers have been labeled already. Enabled by default. [/size][/size][/size][/size][/size][/size]
[font=Courier New]   ﻿"label"[/font]: Adjustments for the appearance and placement of labels.
[/size][/size][/size]
[size=2][size=2][size=2]   ﻿    - [font=Courier New]"capitalize"             [/font]: Capitalizes the label if [font=Courier New]true[/font]. [size=2]Enabled by default.[/size]
   ﻿    - [font=Courier New]"add_parentheses"[/font][size=2][size=2][size=2][font=Courier New]        [/font][/size][/size][/size]: Adds parentheses around the label if [font=Courier New]true[/font]. [size=2]Enabled by default.[/size]
   ﻿    - [font=Courier New]"append"[/font][size=2][size=2][size=2][font=Courier New]                 [/font][/size][/size][/size]: Determines if the label is added before ([font=Courier New]false[/font]) or after ([font=Courier New]true[/font]) the container's name. [size=2]Appends by default.[/size]
   ﻿    - [font=Courier New]"simulate_controller"[/font][size=2][size=2][size=2][font=Courier New]    [/font][/size][/size][/size]: Tries to replicate the [size=2][size=2][size=2]padded '(Empty)' label[/size][/size][/size] seen in the controller UI's search results if [font=Courier New]true[/font]. [size=2]Disabled by default, as it looks bad when using the KB/M UI.[/size]
   ﻿    - [font=Courier New]"display_number_of_items"[/font]:
   ﻿   ﻿   ﻿- [font=Courier New]"enabled"[/font][font=Courier New]  [/font]: [size=2][size=2][size=2]Shows the number of items in a container if [font=Courier New]true[/font]. [size=2]Disabled by default.[/size][/size][/size][/size]
   ﻿   ﻿   ﻿- [font=Courier New]"[/font][font=Courier New]if_empty" [/font]: Shows the number of items even if the container is empty. Enabled by default.

[font=Courier New]   ﻿"filters"[/font]:
   ﻿    - [font=Courier New]"ignored_items"[/font]: Items specified in 'ignored_items.json' (automatically created alongside the config file) will be ignored when counting container items if set to [font=Courier New]true[/font]. [size=2]Enabled by default.[/size]

[size=2][font=Courier New]"DEBUG"[/font]:[/size]
[font=Courier New]   ﻿"level"[/font]: Sets the verbosity of debug logs. [size=2]0 = no debug, 1 = minimal, 2 = verbose. Default is [font=Courier New]0[/font].[/size]

[size=2][size=2][size=2][size=2][size=2][size=2]After saving your changes while the game is running, load a save to reflect your changes or move 6 pieces of gold to a container.[/size][/size][/size][/size][/size][/size]

[/size][/size][line][size=4][b]
[/b][/size][/size][size=5][b]Compatibility[/b][/size]
- This mod should be compatible with most game versions and other mods, as it mostly just changes the DisplayName property of containers/corpses during runtime. Using this with other mods that do the same (I'm not aware of any) might provoke unpredictable behavior where one name change overwrites the other.
- Mods that create new containers should be compatible.
- Localization mods should be compatible.
- Multiplayer: currently, only containers close to the host will be labeled.

[line][size=4][b]
Special Thanks[/b][/size]
[b]Huge thanks to [url=https://www.nexusmods.com/baldursgate3/users/21094599]Focus[/url][/b] for the invaluable help during the early stages of this mod by showing me an alternative when I was about to give up on this idea!; to [url=https://www.nexusmods.com/baldursgate3/users/703937]pavelk[/url] and [url=https://www.nexusmods.com/baldursgate3/users/4227774]Proxa[/url] for their insights when I was still naive enough to consider doing this through some UI interaction 😁; to folks over Larian's Discord server; and to [url=https://github.com/Norbyte]Norbyte[/url] for the Script Extender.

[size=4][b]Source Code
[/b][/size]The source code is available on [url=https://github.com/AtilioA/BG3-preemptively-label-containers]GitHub[/url] or by unpacking the .pak file. Endorse on Nexus and give it a star on GitHub if you liked it!
[line]
[center][b][size=4][/size][/b][center][b][size=4][/size][/b][center][b][size=4]My mods[/size][/b][size=2]
[url=https://www.nexusmods.com/baldursgate3/mods/6995]Waypoint Inside Emerald Grove[/url] - 'adds' a waypoint inside Emerald Grove
[b][size=4][url=https://www.nexusmods.com/baldursgate3/mods/7035][size=4][size=2]Auto Send Read Books To Camp[/size][/size][/url]﻿[size=4][size=2] [/size][/size][/size][/b][size=4][size=4][size=2]- [/size][/size][/size][size=2]send read books to camp chest automatically[/size]
[url=https://www.nexusmods.com/baldursgate3/mods/6880]Auto Use Soap[/url]﻿ - automatically use soap after combat/entering camp
[url=https://www.nexusmods.com/baldursgate3/mods/6540]Send Wares To Trader[/url]﻿[b] [/b]- automatically send all party members' wares to a character that initiates a trade[b]
[/b][b][url=https://www.nexusmods.com/baldursgate3/mods/6313]Preemptively Label Containers[/url]﻿[/b] - automatically tag nearby containers with 'Empty' or their item count[b]
[/b][url=https://www.nexusmods.com/baldursgate3/mods/5899]Smart Autosaving[/url] - create conditional autosaves at set intervals
[url=https://www.nexusmods.com/baldursgate3/mods/6086]Auto Send Food To Camp[/url] - send food to camp chest automatically
[url=https://www.nexusmods.com/baldursgate3/mods/6188]Auto Lockpicking[/url] - initiate lockpicking automatically
[size=2]
[/size][url=https://ko-fi.com/volitio][img]https://raw.githubusercontent.com/doodlum/nexusmods-widgets/main/Ko-fi_40px_60fps.png[/img][/url]﻿﻿[/size][/center][/center][/center][url=https://www.nexusmods.com/baldursgate3/mods/7294][center][/center][center][img]https://i.imgur.com/hOoJ9Yl.png[/img]﻿[/center][/url][center][/center]
