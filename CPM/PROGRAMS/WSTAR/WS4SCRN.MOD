September 15, 1987.

     The new CP/M WordStar v4 comes equipped with a low intensity-high
intensity screen combination that is somewhat difficult to read without
having to adjust the brightness (which means that the brightness has to
be RE-ADJUSTED at the end of the seesion).

The following modification will turn:

1)      WS initialization messages to regular intensity.
2)      The text to regular intensity.
3)      The first print control code(s) and affected text to inverse
        video.
4)      The "^K" blocks and urgent WS messages to blinking. (This is
        the price to pay since WS4 will default to video controlled
        by the byte at WS.COM location 03B9 if the print control codes
        and the "^K" blocks have the same video codes.)
5)      Default and un-initialization to inverse video OFF.

     If you are satisfied by the low intensity messages do not change
the first byte (038F).

Procedure:

Enter WSCHANGE <CR>

     When asked for the file to read from, enter the name of your
WordStar file <CR> (usually WS if you did not rename it).  When asked
for the name of the file to write to, enter WSMODIF <CR> (to keep your
original file until you check the modified file and are satisfied with
it).

At the first menu enter A <CR>
At the next menu enter C <CR>
At the third menu :
enter = then 038F <CR> then 43 then X (message video control)
enter = then 03B9 <CR> then 30 then X (default and un-initialize)
enter = then 0401 <CR> then 32 then X (blinking)
enter = then 0404 <CR> then 42 then 30 then X (inverse video ON)
enter = then 040D <CR> then 32 then X (blinking)
enter = then 0410 <CR> then 43 then 30 then X (inverse video OFF)
then X then X then answer Y(yes) at the prompt.

     If everything was done properly you have patched your WS4 to the
new settings and they have been written in a new file called WSMODIF.
You can try and then delete and rename as you like.

     One thing I do not like is the inconsistent emphasis on print
controls; the first toggle is emphasized as is the affected text, the
second toggle is regular video (same thing for the underline). Either
both toggles or none should be emphasized.  If anyone has the time to
tackle that problem please leave a message on:

                                   LiKug RBBS   (516) 825-8465   or
                                   Pro-Gram RBBS (516)932-7674

Philippe Cauvet, LIKUG.
