# sourcemod-nt-fovchanger
A plugin for Neotokyo that provides the following change:

Allow patched clients to set their preferred field of view.

## Background
During the development of the game the default player field of view was fixed to 75 degrees which has been reported to cause motion sickness in some players. This plugin and client patch aim to provide a long needed QoL improvement by allowing the player to set their preferred field of view.

## What this plugin does
This plugin detects clients running appropriately patched game binaries and allows them to set their field of view by using the `!fov` command in-game. If a unpatched client tries to use the !fov command they are communicated a link to download the patch. Client preferences are stored for consistency between sessions.

Clients are required to use a patched client.dll in order to use functionality of this plugin. Client binaries are patched to restore the functionality between networked m_iDefaultFOV and rendered field of view. Additionally, a "magic byte" patch detection is implemented. The plugin checks for the presence of a custom client cvar in order to confirm the presence of the patch.

## Build requirements
* SourceMod 1.8 or newer

## Installation (Server)
* Move the compiled .smx binary to `addons/sourcemod/plugins`

## Installation (Client)
* Create a backup of client.dll in `...\SteamLibrary\steamapps\common\NEOTOKYO\NeotokyoSource\bin\`
* Download the patched binaries (client.dll) from `TBA` and overwrite existing file in `...\SteamLibrary\steamapps\common\NEOTOKYO\NeotokyoSource\bin\`
* Run any other binary patcher such as NTCore's LAA patch
* Alternatively download the Python binary patcher script, point it to your existing LAA-patched or LAA-unpatched client.dll and run it

## Uninstallation (Client)
* Overwrite patched client.dll with a backup of the original file
* Note that verifying integrity of game files on Steam will also replace the patched binaries with original game files although this runs the risk of possibly losing other modifications as well

## Important notes regarding binary patching

The plugin requires clients to have patched game binaries in order to provide any meaningful functionality to players. Binary patching is considered a high-risk activity and may result in anticheat-related consequences. The absence of VAC in Neotokyo has not been confirmed by me, Lilihierax, and this plugin-patch concept relies on empirical observations from the community using NTCore's LAA patch extensively without unforeseen consequences as well as [comments made by Valve Software employees](https://github.com/ValveSoftware/source-sdk-2013/issues/76#issuecomment-21562961).

Unfortunately it is impossible to know how Valve will treat Source-engine mods such as Neotokyo in the future (in the context of anticheating).

Make any modifications to your game binaries at your own risk.

## Usage
* Players can access the FoV menu by typing `!fov` in chat or set their desired field of view instantly by including it as a parameter, ex. `!fov 95` will set the player's field of view to 95 degrees
* Server operators can define the range of acceptable field of view values by using `sm_nt_fov_min` and `sm_nt_fov_max`

## Reporting issues

* Issues and glitches caused by this modification can be also reported on Active Neotokyo Players ("ANP") [Discord server](https://discord.gg/JJBMzeqfdh)

## Authors
* Plugin code and development by Rain
* Original research and proof of concept plugin by Lilihierax
* Additional thanks to Kudegra and Jef for their efforts in reverse engineering Neotokyo

## Changelog
* 0.1.0 - Initial proof of concept release (March 2023) for NEOTOKYO° (Steam App ID: 244630, Steam Build ID: 1981783) by Lilihierax
* 0.2.0 - Initial release of reworked plugin by Rain: added min/max bounds for the FoV, optional graphical menu, binary patch detection using the "fovispatched" client cvar and clientprefs
