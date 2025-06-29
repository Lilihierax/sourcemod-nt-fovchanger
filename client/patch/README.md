## Using the Python script

* Download and install [Python](https://www.python.org/downloads/)
* Run the script in Windows Command Prompt, PowerShell or similar including the path to your client.dll as an argument
* A backup of the original file will be created automatically in the same folder
* For example: `python "C:/Users/Username/Desktop/nt_fovchanger_client_patch.py" "C:\Program Files (x86)\Steam\steamapps\common\NEOTOKYO\NeotokyoSource\bin\client.dll"`

## Manual patching with a hex editor
* Create a backup of client.dll in `...\SteamLibrary\steamapps\common\NEOTOKYO\NeotokyoSource\bin\`
* Open your preferred hex editor, Maël Hörz's [HxD](https://mh-nexus.de/en/hxd/) works nicely and is freeware
* To patch the netprop go to offset `2166B2` (h)
* Change the next three bytes from `64 17 30` to `D8 8A 3F`

![nt_fovchanger_manual_patching_01](https://github.com/Lilihierax/sourcemod-nt-fovchanger/assets/140167708/13a4c763-3dff-498b-b026-d260d1ab4db8)

* To patch the magic byte go to offset `30940C` (h)
* Change the next 12 bytes from `63 6C 6F 73 65 63 61 70 74 69 6F 6E` to `66 6F 76 69 73 70 61 74 63 68 65 64`

![nt_fovchanger_manual_patching_02](https://github.com/Lilihierax/sourcemod-nt-fovchanger/assets/140167708/3fc8242a-533f-44b6-90d8-5af39a91118a)

* Save the file

# Uninstallation
* Overwrite patched client.dll with a backup of the original file
* Note that verifying integrity of game files on Steam will also replace the patched binaries with original game files although this runs the risk of possibly losing other modifications as well
