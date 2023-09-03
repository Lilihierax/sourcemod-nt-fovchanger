#!/usr/bin/env python3

# Patch for the NT client binary (client.dll) to enable SourceMod plugin support for field-of-view control.

import os
import shutil
import sys

def create_file_backup(file_path):
    backup_file = f"{file_path}.bak"
    shutil.copy(file_path, backup_file)
    print(f"Backup created: {backup_file}")
    return backup_file

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

        print("Patching successful!")

    except Exception as e:
        print(f"Error: {e}")
        if os.path.exists(backup_path):
            print("Restoring backup...")
            shutil.move(backup_path, file_path)
            print("Backup restored.")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python nt_fovchanger_client_patch.py <client_dll_file_path>")
        sys.exit(1)

    dll_file_path = sys.argv[1]
    if not os.path.isfile(dll_file_path):
        print("Error: The specified file does not exist.")
        sys.exit(1)

    # Patch the .dll
    patch_file(dll_file_path)
