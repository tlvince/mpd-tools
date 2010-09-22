#!/usr/bin/python3

import os
import sqlite3

DB = os.path.expanduser("~") + "/.mpdcron/stats.db"
IN = os.path.expanduser("~") + "/eugene-plays"
OUT = os.path.expanduser("~") + "/plays.log"
PREFIX = "1970-01-01T00:00:00+0000"

songs = []
with open(IN) as file:
    for line in file:
        arr = line.split(":")
        tup = (arr[0], arr[2].rstrip('\n'))
        songs.append(tup)

with open(OUT, mode='w', encoding='utf-8') as outFile:
    conn = sqlite3.connect(DB)
    c = conn.cursor()

    for song in songs:
        c.execute('SELECT artist,title FROM song WHERE id=' + song[0])
        track = c.fetchone()
        for i in range(int(song[1])):
            outFile.write(PREFIX + " " + track[0] + " - " + track[1] + "\n")

