![nt_fovchanger_banner_github](https://github.com/Lilihierax/sourcemod-nt-fovchanger/assets/140167708/f8b40331-cc20-4feb-a1ba-f17c999f9dfc)

# sourcemod-nt-fovchanger
A plugin for Neotokyo that provides the following change:

Allow patched clients to set their preferred field of view.

## Background
During the development of the game the default player field of view was fixed to 75 degrees which has been reported to cause motion sickness in some players. This plugin and client patch aim to provide a long needed QoL update by allowing players to set their preferred field of view.

## What this plugin does
This plugin detects clients running appropriately patched game binaries and allows them to set their field of view by using the `!fov` command in-game. If a unpatched client tries to use the command they are communicated a link to download the patch. Client preferences are stored for consistency between sessions.

Clients are required to use a patched client.dll in order to use the functionality of this plugin. Client binaries are patched to restore the connection between a netprop (m_iDefaultFOV) and a field of view engine cvar. Additionally, a "magic byte"-style patch detection is implemented by renaming a unused engine cvar. The plugin checks for the presence of the modified engine cvar in order to confirm the presence of the patch.

## Build requirements
* SourceMod 1.7 or newer

## Installation (Server)
* Move the compiled .smx binary to `...\addons\sourcemod\plugins\`

## Installation (Client)
* Create a backup of client.dll in `...\SteamLibrary\steamapps\common\NEOTOKYO\NeotokyoSource\bin\`
* Download patched binaries (client.dll) from [sourcemod-nt-fovchanger/client/bin/](client/bin/)
* Overwrite existing file in `...\SteamLibrary\steamapps\common\NEOTOKYO\NeotokyoSource\bin\`
* Optional: run a LAA patcher such as NTCore's LAA patch to re-enable /LARGEADDRESSAWARE flag if you were using patched binaries before
* Alternatively download the Python binary patcher script and follow [these instructions](https://github.com/Lilihierax/sourcemod-nt-fovchanger/tree/main/client/patch) to patch the file
* Alternatively use a hex editor of your choice and follow [these instructions](https://github.com/Lilihierax/sourcemod-nt-fovchanger/tree/main/client/patch) to manually patch the file

## Uninstallation (Client)
* Overwrite patched client.dll with a backup of the original file
* Note that verifying integrity of game files on Steam will also replace the patched binaries with original game files although this runs the risk of possibly losing other modifications as well

## Important notes regarding binary patching
The plugin requires clients to have patched game binaries in order to provide any meaningful functionality to players. Binary patching - or rather using modified game binaries - is considered a high-risk activity and may result in anticheat-related consequences. The absence of VAC in Neotokyo has not been throughoughly confirmed by me, Lilihierax, and the safe use of this plugin-patch concept relies entirely on empirical observations from the community using NTCore's LAA patch extensively over a long period of time without unforeseen consequences as well as [comments made by Valve Software employees](https://github.com/ValveSoftware/source-sdk-2013/issues/76#issuecomment-21562961).

Unfortunately it is impossible to know how Valve will treat Source-engine mods such as Neotokyo in the future (in the context of anticheating).

I will not be held responsible for any damages, incl. changes in VAC standing, resulting from the use of this patch. Make any modifications to your game binaries at your own risk.

## Usage
* Players can access the FOV menu by typing `!fov` in chat
* Players can also set their desired field of view instantly by including it as a parameter, e.g. `!fov 95`
* Server operators can define the range of acceptable field of view values by using `sm_nt_fov_min` and `sm_nt_fov_max`

## Known issues
* Zooming with weapons can cause snapping-like behavior. This effect is most prominent when a weapon is zoomed out while a high field of view is being used
* Viewmodel field of view stays fixed and is not affected by changes to world field of view
* Prop fade issues can be triggered by high field of view values, i.e. distant props (level assets) stop being rendered - and providing occlusion - prematurely at relatively high distances from the player
* Issues and glitches caused by this modification can be reported as a GitHub issue or alternatively on Active Neotokyo Players ("ANP") [Discord server](https://discord.gg/JJBMzeqfdh)

## Authors
* Plugin development by Rain
* Patcher by Rain, Lilihierax
* Original research and proof of concept plugin by Lilihierax
* Additional thanks to Kudegra and Jef for their efforts in reverse engineering Neotokyo
* Additional thanks to Dennogin and Milk for playtesting

## Changelog
* 0.1.0 - Initial proof of concept release (March 2023) for NEOTOKYO° (Steam App ID: 244630, Steam Build ID: 1981783) by Lilihierax
* 0.2.0 - Initial release of reworked plugin by Rain: added min/max bounds for the FOV, optional graphical menu, binary patch detection using the "fovispatched" client cvar and clientprefs
