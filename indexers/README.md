# Modern Indexers

The Walnut Creek CP/M CD contains files in each directory called `00-INDEX.TXT`, which contain a description of each file as well as the size and timestamp.  The software in this directory aims to provide various interface for browsing the files on the CD with an interface basically approximating that of the `VIEW.EXE` DOS program included in the CD:

- `index_gopher.py` parses the `00-INDEX.TXT` file in the each directory and converts it to a `gophermap` file in the same directory.  This can be run using `python index_gopher.py`.
- Later, I may also implement the following:
  - Telnet command-line interface for use with a terminal program on platforms that don't have a gopher browser.
  - Oldskool web interface that is basically a simulated gopher interface with `<pre>` formatted ASCII and links.