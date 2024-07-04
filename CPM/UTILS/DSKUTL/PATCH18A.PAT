               PATCHES AND CORRECTIONS TO PATCH18A

     The  following  patches  and corrections  to  PATCH18A   may
clarify  an ambiguity present in the menu of that program and  an
error in the documentation.

     1.  It would be clearer to have the  menu read "dIr" instead
of  "Dir" to better indicate that directories may be accessed  by
typing  "i"  or "I".  The capital "D" of  the  Directory  command
could  cause confussion with the "D" of the "Disk  No."  command.
The following patches can be made using PATCH18A:

          address           was            change to
           2EA6              D                 d
           2EB5              i                 I


     2. The "Disk No. (A - P)" message that occurs when the "Disk
No."  command is accessed, can be corrected to the  actual  "top"
drive letter by changing the "P" that occurs at address 5F64.
 
     3.   Also;  the documentation for PATCH18A states  that  "To
change  from the HEX field to the ASCII, or visa versa,  enter  a
^F."  In fact; you should use ^A to access this command.

     I hope you find these changes helpful.

                                        Wayne Smith
                                       5 January 1988
