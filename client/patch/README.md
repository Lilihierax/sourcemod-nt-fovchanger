## Using the Python script

Insert Python patcher script instructions here.

## Manual patching in a hex editor

* Open your preferred hex editor like Maël Hörz's [HxD](https://mh-nexus.de/en/hxd/)
* To patch the netprop go to offset `2166B2` (h)
* Change the next three bytes from `64 17 30` to `D8 8A 3F`
* To patch the magic byte go to offset `30940C` (h)
* Change the next 12 bytes from `63 6C 6F 73 65 63 61 70 74 69 6F 6E` to `66 6F 76 69 73 70 61 74 63 68 65 64`
* Save the file
