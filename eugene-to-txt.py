#!/usr/bin/python3

import os
import sqlite3

DB = os.path.expanduser("~") + "/.mpdcron/stats.db"
OUT = os.path.expanduser("~") + "/plays.log"
PREFIX = "1970-01-01T00:00:00+0000"

conn = sqlite3.connect(DB)
c = conn.cursor()
c.execute("SELECT artist,title,play_count FROM song WHERE play_count !='0'")
songs = (c.fetchall())

with open(OUT, mode='w', encoding='utf-8') as outFile:
    for song in songs:
        for i in range(int(song[2])):
            outFile.write(PREFIX + " " + song[0] + " - " + song[1] + "\n")
    conn.close
