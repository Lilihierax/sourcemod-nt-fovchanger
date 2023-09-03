## Using the Python script

* Download and install [Python](https://www.python.org/downloads/)
* Run the script including the path to your client.dll as the argument
* For example: `python "c:/Users/User/Desktop/nt_fovchanger_client_patch.py" "C:\Program Files (x86)\Steam\steamapps\common\NEOTOKYO\NeotokyoSource\bin\client.dll"`

## Manual patching with a hex editor
* Open your preferred hex editor, Maël Hörz's [HxD](https://mh-nexus.de/en/hxd/) works nicely and is freeware
* To patch the netprop go to offset `2166B2` (h)
* Change the next three bytes from `64 17 30` to `D8 8A 3F`
![nt_fovchanger_manual_patching_01](https://github.com/Lilihierax/sourcemod-nt-fovchanger/assets/140167708/2608aece-2c58-425d-b3c3-ca8c578f98a2)
* To patch the magic byte go to offset `30940C` (h)
* Change the next 12 bytes from `63 6C 6F 73 65 63 61 70 74 69 6F 6E` to `66 6F 76 69 73 70 61 74 63 68 65 64`
![nt_fovchanger_manual_patching_02](https://github.com/Lilihierax/sourcemod-nt-fovchanger/assets/140167708/465bc492-d3af-4915-8ca1-5d762acc2aa6)
* Save the file
