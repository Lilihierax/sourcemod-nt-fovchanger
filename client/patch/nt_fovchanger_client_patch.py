#!/usr/bin/env python3

# Patches the NT client binary (client.dll) to enable SourceMod plugin support for field-of-view control.
# 3 bytes are patched at offset 2166B2 (h) to connect m_iDefaultFOV with a engine fov cvar.
# 12 bytes are patched at offset 30940C (h) to modify a unused engine cvar to be used for patch detection from server side. 

import os
import shutil
import sys

def create_file_backup(file_path: str) -> bool:

    # Backs up the file_path as file_path.bak, if the backup doesn't exist yet
    backup_file = f"{file_path}.bak"
    if not os.path.exists(backup_file):
        print(f'Backing up file "{file_path}" as "{backup_file}"')
        shutil.copyfile(file_path, backup_file)
        return True
    print(f'Skipping writing of backup file "{backup_file}" since it already exists.')
    return False

def patch_file(file_path):
    try:
        # Create a backup of the original file
        backup_path = create_file_backup(file_path)

        # Define the patch data and offsets
        patch_data = [
            (b"\xD8\x8A\x3F", 0x2166B2),  # Netprop, 3 bytes at offset 2166B2 (h)
            (b"\x66\x6F\x76\x69\x73\x70\x61\x74\x63\x68\x65\x64", 0x30940C),  # Magic byte, 12 bytes at offset 30940C (h)
        ]

        # Read the binary file
        with open(file_path, "rb+") as dll_file:
            for data, offset in patch_data:
                dll_file.seek(offset)
                dll_file.write(data)
        offset_str = ", ".join(hex(offset) for _, offset in patch_data)
        print(f"Successfully patched byte(s) at offset(s): {offset_str}")
        print("Patching successful!")

    except Exception as e:
        print(f"Error: {e}")
        if os.path.exists(backup_path):
            print("Restoring backup...")
            shutil.move(backup_path, file_path)
            print("Backup restored.")
        sys.exit(1)

def main() -> None:

    # Entry point
    if len(sys.argv) != 2:
        print(
            f'Usage: python "{sys.argv[0]}" <client_dll_file_path>'
        )
        return

    file_path = sys.argv[1]
    assert os.path.exists(file_path), f"Path doesn't exist: {file_path}"
    assert os.path.isfile(file_path), f"Path is not a file: {file_path}"

    # Patch the .dll
    patch_file(file_path)
    sys.exit(0)

if __name__ == "__main__":
    main()
