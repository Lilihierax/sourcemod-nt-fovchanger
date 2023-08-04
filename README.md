# sourcemod-nt-fovchanger
A plugin for Neotokyo that provides the following change:

Allow patched clients to set their preferred field of view.

## Background
During development the default player field of view was fixed to 75 degrees which has been reported to cause motion sickness and nausea in some players. This plugin and client patch aim to provide a long needed QoL improvement by allowing the player to set their preferred field of view.

## What this plugin does
This plugin detects clients running appropriately patched game binaries and allows them to set their field of view by using the !fov command in-game. If a unpatched client tries to use the !fov command they are communicated a link to download the patch. Client preferences are stored for consistency between sessions.

## Build requirements
* SourceMod 1.8 or newer

## Installation (Server)
* Move the compiled .smx binary to `addons/sourcemod/plugins`

## Installation (Client)
* Download the patched binaries from `TBA` and overwrite existing file in `...\SteamLibrary\steamapps\common\NEOTOKYO\NeotokyoSource\bin\client.dll`
* Alternatively download the Python binary patcher script and run it
