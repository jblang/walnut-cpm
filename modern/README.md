# Modern Indexers

The software in this directory aims to provide various interface for browsing the files on the Walnut Creek CP/M CD:

- `index.py`, which parses the "00-INDEX.TXT" file in the each directory and converts it to a `gophermap` file in the same directory. This can be used to serve the files via gopher.
- `gopher.py` runs a gopher server that roughly approximates the interface of the VIEW.EXE DOS program in the root directory.  
  - The script uses the [Pitophius](https://github.com/dotcomboom/Pituophis) gopher library for Python. It can be installed with `pip install pituophis`.
  - This has been tested with [Gophie](https://gophie.org/) on Windows and [Snail](https://github.com/nihirash/agon-snail) on the Agon.
- Later, I may also implement the following:
  - Telnet command-line interface for use with a terminal program on platforms that don't have a gopher browser.
  - Oldskool web interface that is basically a simulated gopher interface with `<pre>` formatted ASCII and links.