Dallas TX 09-26-84

LU (Library Utility) by Gary Novosielski was written mostly in BDS C.
While BDS C is one of the best CP/M-80 C compilers, it seems to second-guess
sometimes, which is what brings trouble under other operating systems,
in this case TurboDOS.

While LU ran fine under earlier versions of TurboDOS, it failed to run
properly under version 1.40. It seemed every time it made a console status
call it would "see" a character and wait for keyboard entry. This way one
had to hold down a repeating key while LU was extracting or whatever.

Turns out, LU (BDS C actually) uses unpublished information to see if a
console character has been typed. Using BDOS call 11, the accumulator
will return 00 if there is no console input or FF if there is a character
waiting. In CP/M, HL will contain 0000 if no character else 0001. BDS C
uses the (UNPUBLISHED!) value in HL to check console status rather than
A. TurboDOS (and it may or may not have a bug there, but I wouldn't argue
because HL is not defined as return value) returns HL=undefined if there
is no character, or 00FF if there is.

The following patch will fix LU to work properly under TurboDOS. Please
note that this patch utilizes string storage used to contain the
error message, "EXECL: Command line overflow" and will shorten that
message to just "EXECL".

The patch applies to LU300.COM...

1. Using your favorite debugger, replace
   4514  CALL 0005
   with
   4514  CALL 4BAD

2. Now, change location 4BAC from
   4BAC  3A
   to
   4BAC  24

3. Finally, assemble the following at 4BAD:
   4BAD  CPI 0B
   4BAF  JNZ 0005
   4BB2  CALL 0005
   4BB5  MVI H,00
   4BB7  MOV L,A
   4BB8  RET

4. Now save the modified LU.

Note that the above fix...

- has not yet been approved by the author
- has been tested under TurboDOS 1.40
- will not affect CP/M operation


For more helpful hints, programs and info on TurboDOS, subscribe to
SENECA RCPM (soon to be RTDS). 214-553-1363
