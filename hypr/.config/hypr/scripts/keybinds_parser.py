#!/usr/bin/env python3
import os
import re
import sys

def parse_lua_bind(line):
    line = line.strip()
    
    # Check for our custom `bind(key, action, desc, opts)` wrapper
    if line.startswith("bind(") and not line.startswith("bind(key,"):
        desc = ""
        # The description is always a string literal at the end before optional {} opts
        desc_match = re.search(r',\s*"([^"]+)"\s*(?:,\s*\{[^}]*\})?\s*\)$', line)
        if desc_match:
            desc = desc_match.group(1)
            
        key_match = re.search(r'^bind\(\s*(.*?)\s*,', line)
        if not key_match:
            return None
            
        key_part = key_match.group(1)
        key_part = key_part.replace('mainMod .. ', 'SUPER')
        key_part = key_part.replace('"', '').replace("'", "")
        key_part = key_part.replace(' + ', '+')
        
        if desc:
            return f"{key_part} — {desc}"
        else:
            # Try to get the command (second arg)
            # Remove the key part and optional opts to find the command
            cmd_match = re.search(r'^bind\(\s*[^,]+,\s*(.+?)(?:,\s*nil)?(?:,\s*\{.*?\})?\)$', line)
            if cmd_match:
                cmd = cmd_match.group(1).strip()
                if cmd.endswith(','): cmd = cmd[:-1]
                return f"{key_part} — {cmd}"
            return key_part
            
    # Check for original `hl.bind(key, action, opts)`
    elif line.startswith("hl.bind(") and not line.startswith("hl.bind(key,"):
        desc_match = re.search(r'description\s*=\s*"([^"]+)"', line)
        desc = desc_match.group(1) if desc_match else ""
        
        key_match = re.search(r'hl\.bind\(\s*(.*?)\s*,', line)
        if not key_match:
            return None
            
        key_part = key_match.group(1)
        key_part = key_part.replace('mainMod .. ', 'SUPER')
        key_part = key_part.replace('"', '').replace("'", "")
        key_part = key_part.replace(' + ', '+')
        
        if desc:
            return f"{key_part} — {desc}"
        else:
            cmd_match = re.search(r'hl\.bind\(\s*[^,]+,\s*(.+?)(?:,\s*\{[^}]*\})?\)$', line)
            if cmd_match:
                cmd = cmd_match.group(1).strip()
                if cmd.endswith(','): cmd = cmd[:-1]
                return f"{key_part} — {cmd}"
            return key_part
            
    return None

def main():
    if len(sys.argv) < 2:
        sys.exit(0)

    config_files = sys.argv[1:]
    raw_keybinds = []

    for file_path in config_files:
        if not os.path.exists(file_path):
            continue
            
        try:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    parsed = parse_lua_bind(line)
                    if parsed:
                        raw_keybinds.append(parsed)
        except Exception as e:
            sys.stderr.write(f"Error reading {file_path}: {e}\n")

    if not raw_keybinds:
        print("no keybinds found.")
        sys.exit(1)

    for bind in raw_keybinds:
        print(bind)

if __name__ == "__main__":
    main()
