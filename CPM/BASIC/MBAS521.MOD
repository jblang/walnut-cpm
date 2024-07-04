MBASIC Rev. 5.21 DELete key modification

		By Tom Harrold    NOV,1984

	I have scaned  the local  BBS  for a  doc to  modify
MBASIC to make the DEL key to do the same as Back space key.
I  found  one   that   was  called   "MBASIC.MOD".  Well  it
did not work  with my  MBASIC.COM  so,   I took on the task.
The following  will allow  you to  modify  MBASIC REV. 5.21. 
You must  have on a  disk  containing   MBASIC.COM,  DDT.COM 
(or  SID.COM),   and  plus   24k  bytes of  space  on  disk.

THIS WILL CHANGE THE DELETE KEY TO FUNCTION LIKE BACK SPACE.

A>MBASIC		<---- TYPE mbasic to test if you need this mod.

BASIC-80 Rev. 5.21			<--- mbasic sign on message.
[CP/M Version]
Copyright 1977-1981 (C) by Microsoft
Created: 28-Jul-81
30776 Bytes free
Ok

TOX\X\M		<--- type something, I typed tom and then press del key.
Syntax error		if it do not print a slash "\" then forget this
Ok
LISTY\Y\	<--- another example: I typed "list" and "y" and then del.
Ok			this is to show how the del key works, it sucks!
SYSTEM		<--- get back to cp/m.
A>DDT MBASIC.COM	<--- now, type "ddt mbasic.com"
DDT VERS 2.2
NEXT  PC
6000 0100
-G0		<--- EXIT DDT
A>SAVE 96 MBASIC.BAK	<--- save a copy of mbasic
A>DDT MBASIC.COM	<--- get into ddt again with mbasic
DDT VERS 2.2
NEXT  PC
6000 0100

-L4B41 <--- type L and 4b41  and compare the following to your list.


  4B41  LDA  0792
  4B44  ORA  A
  4B45  MVI  A,5C
  4B47  STA  0792
  4B4A  JNZ  4B55
  4B4D  DCR  B
  4B4E  JZ   4B27
  4B51  CALL 40D6
  4B54  INR  B
  4B55  DCR  B
  4B56  DCX  H
-
-A4B41		<--- type A and 4b41 then return.
4B41  MVI A,08	<--- type "mvi a,08"
4B43  JMP 4BBC	<--- type "jmp 4bbc"
4B46  .		<--- end assembly
-
-L4B41	<--- type L and 4b41  and compare the following to your list.

  4B41  MVI  A,08
  4B43  JMP  4BBC
  4B46  MOV  E,H
  4B47  STA  0792
  4B4A  JNZ  4B55
  4B4D  DCR  B
  4B4E  JZ   4B27
  4B51  CALL 40D6
  4B54  INR  B
  4B55  DCR  B
  4B56  DCX  H
-G0	<--- type G and 0 to get back to cp/m.
A>SAVE 96 MBASIC.COM	<--- save your new mbasic.com
A>MBASIC	<--- and test it out.
A>ERA MBASIC.BAK  <--- type this if you like the new mod, 
	If some how its not working for you, give it to somebody that can
or drop the whole thing and go back and REName mbasic.bak to mbasic.com.
	type the following: REN MBASIC.COM=MBASIC.BAK


sincerly yours Tom Harrold.
