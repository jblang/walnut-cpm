# Modern Indexer

The software in this directory aims to implement a modern interface to browse the files on the Walnut Creek CP/M CD:

- Right now, there is `index.py`, which parses the "00-INDEX.TXT" file in the root directory and outputs `index.json` (json index) and `index.db` (sqlite index) in this directory.
- The next goal is to implement a gopher server that simulates the interface of the VIEW.EXE DOS program in the root directory.  This will be useful for navigating the repository using the [Snail](https://github.com/nihirash/Agon-MOS-Tools/tree/main/esp8266/snail) gopher browser on the Agon.
- After that, I may also implement the following:
  - Telnet command-line interface for use with a terminal program on platforms that don't have a gopher browser.
  - Oldskool web interface that is basically a simulated gopher interface with `<pre>` formatted ASCII and links.