#!/usr/bin/env python3

import sys
import pituophis

if len(sys.argv) >= 2:
    addr = sys.argv[1]
else:
    addr = "127.0.0.1"
pituophis.serve(addr, pub_dir="..")