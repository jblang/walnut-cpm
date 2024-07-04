#!/usr/bin/env python3

import sqlite3
import os
import json
from pathlib import Path

def parse_header(data):
    data = data.splitlines()
    return {
        "path": data[1].strip().split(":")[1].strip().split("\\")[1:],
        "desc": data[0].strip()
    }
    
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
    
def parse_directory(data):
    lines = data.strip().splitlines()
    files = []
    for line in lines[2:]:
        line = line.strip()
        if line.startswith("|"):
            files[-1]["desc"] += "\n" + line[2:].strip()
        else:
            files.append(parse_file(line))
    return files

def parse_index(filename):
    directories = []
    with open(filename) as f:
        data = f.read().replace("\r\n", "\n")
        sections = data.split("\n--------------------------------------\n")
        for section in sections:
            section = section.strip()
            if section.startswith("Name             Size    Date    Description"):
                directories[-1]["files"] = parse_directory(section)
            else:
                directories.append(parse_header(section))
    return directories
def file_dir():
    return Path(__file__).parent.absolute()

def root_dir():
    return file_dir().parent.absolute()

def input_file():
    return root_dir().joinpath("00-INDEX.TXT")

def json_file():
    return file_dir().joinpath("index.json")

def db_file():
    return file_dir().joinpath("index.db")

CREATE_TABLES = """
CREATE TABLE IF NOT EXISTS directories (
    path text,
    desc text
);

CREATE TABLE IF NOT EXISTS files (
    path text,
    name text,
    size integer,
    date text,
    desc text
);
"""

INSERT_DIR = "INSERT INTO directories (path, desc) VALUES(?, ?)"

INSERT_FILE = """
INSERT INTO files (path, name, size, date, desc)
VALUES(:path, :name, :size, :date, :desc);
"""

def sqlite_index(index):
    try:
        os.remove(db_file())
    except Exception:
        pass
    path = None
    db = sqlite3.connect(db_file())
    db.executescript(CREATE_TABLES)
    for directory in index:
        path = "/".join(directory["path"])
        desc = directory["desc"]
        db.execute(INSERT_DIR, (path, desc))
        for file in directory["files"]:
            file["path"] = path
            db.execute(INSERT_FILE, file)
    db.close()
    
if __name__ == "__main__":
    index = parse_index(input_file())
    with open("index.json", "w") as f:
        json.dump(index, f, indent=4)
    sqlite_index(index)
