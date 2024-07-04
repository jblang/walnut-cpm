Date: Friday, 13 April 1984
From: Jack Bicer
To:   Aztec C Users

Someone complained that Aztec C creates a large COM file (compared to what???).
Keep the code below in seperate file, and include it when linking your modules
(order doesn't matter, but before libc.lib). I call this file minroot.c and
minroot.o for source and relocatible versions respectively.
-----------------------------------------------------------------------
Croot()
{
    exit(main());
}

exit(code)
{
    boot@();  /* @ sdands for underline character. These keyboards!!! */ 
}

badfd()
{
    return -1;
}

noper()
{
    return 0;
}
----------------------------------------------------------------------
The result of the program  "main() { }" (which shows size of the runtime
package) is:
  with minroot.o = 7 sectors --> 896 bytes
  without        =36 sectors -->4608 bytes
  
  But if you use the buffered I/O library (printf does!), then the necesseary
  code gets linked in and the size of the COM file is the same as before.
  
  	Jack Bicer
