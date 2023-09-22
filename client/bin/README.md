# Installation
* Create a backup of client.dll in `...\SteamLibrary\steamapps\common\NEOTOKYO\NeotokyoSource\bin\`
* Download patched binaries (client.dll) from [sourcemod-nt-fovchanger/client/bin/](client/bin/)
* Overwrite existing file in `...\SteamLibrary\steamapps\common\NEOTOKYO\NeotokyoSource\bin\`

# Uninstallation
* Overwrite patched client.dll with a backup of the original file
* Note that verifying integrity of game files on Steam will also replace the patched binaries with original game files although this runs the risk of possibly losing other modifications as well

## SHA-256 hash for unmodified Neotokyo client.dll
* Steam App ID: 244630, Steam Build ID: 1981783
* SHA-256 hash: `5E36764E351D55CAF7192D184D35C37FC9175F823CE2E2355384571740550D35`

## SHA-256 hash for modified Neotokyo client.dll
* Steam App ID: 244630, Steam Build ID: 1981783
* Netprop and magic byte patched
* SHA-256 hash: `0FBD61E2F2BA5A0C682E033FFBC2B56804E2056E737A3D6200FAE8060805BA2F`
