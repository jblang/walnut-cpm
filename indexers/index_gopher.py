#!/usr/bin/env python3

import os
from pathlib import Path

def parse_date(date):
    m, d, y = date.strip().split("-")
    return f"19{y}-{m}-{d}"
        
def parse_file(data):
    data = data.strip()
    return {
        "name": data[:12].strip(),
        "size": int(data[14:22].strip()),
        "date": parse_date(data[23:32].strip()),
        "desc": data[33:].strip(),
    }
    
def parse_dir(data):
    lines = data.strip().splitlines()
    files = []
    for line in lines:
        line = line.strip()
        if line.startswith("|"):
            files[-1]["desc"] += "\n" + line[2:].strip()
        else:
            files.append(parse_file(line))
    return files

def script_dir():
    return Path(__file__).parent.absolute()

def root_dir():
    return script_dir().parent.absolute()

def cd_file(path):
    return root_dir().joinpath(path)

TEXTCHARS = bytearray({7,8,9,10,12,13,26,27} | set(range(0x20, 0x100)) - {0x7f})

def is_binary(filename):
    with open(filename, "rb") as f:
        bytes = f.read()
    return bool(bytes.translate(None, TEXTCHARS))

def read_lines(file):
    return file.read().replace("\r\n", "\n").strip().splitlines()

def parse_index(path):
    if path == root_dir():
        return
    relpath = os.path.relpath(path, root_dir()).replace("\\", "/")
    index = os.path.join(path, "00-INDEX.TXT")
    if not os.path.exists(index):
        return
    menu = [
        f"!Walnut Creek CP/M CD-ROM: {relpath}",
        "=" * 80,
        "",
        "Name             Size  Date        Description",
        "------------     ----  ----        -----------"
    ]
    with open(index) as f:
        lines = read_lines(f)
    for line in lines:
        line = line.strip()
        if line.startswith("|"):
            # continuation of previous file's description
            menu.append(" " * 31 + line)
        else:
            # file or directory entry
            name = line.strip().split()[0]
            if "<DIR>" in line:
                tchar = "1" # directory
            elif is_binary(cd_file(os.path.join(path, name))):
                tchar = "9" # binary
            else:
                tchar = "0" # text
            menu.append(f"{tchar}{line}\t{name}")
    gophermap = os.path.join(path, "gophermap")
    with open(gophermap, "w") as f:
        f.write("\n".join(menu))

def parse_dirs():
    menu = [
        "!Walnut Creek CP/M CD-ROM",
        "=" * 80,
        "",
    ]
    with open(cd_file("DIRS.TXT")) as f:
        lines = read_lines(f)
    for line in lines:
        path = line.split()[0]
        if "<DIR>" in line:
            tchar = "1"
        else:
            tchar = "0"
        menu.append(f"{tchar}{line}\t{path}")
    with open(cd_file("gophermap"), "w") as f:
        f.write("\n".join(menu))

def main():
    parse_dirs()
    for root, dirs, files in os.walk(root_dir()):
        for name in dirs:
            path = os.path.join(root, name)
            if path != root_dir():
                print(f"Indexing {path}...")
                parse_index(path)    
    
if __name__ == "__main__":
    main()