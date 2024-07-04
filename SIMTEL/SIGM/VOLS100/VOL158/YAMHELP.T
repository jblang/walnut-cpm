Yamhelp.t	Help File for YAM	Rev 8/22/82 lba


*****************************************************************
*								*
*		Notation					*
*								*
*****************************************************************

 {}	= Required argument.

 [] = Optional argument.

 ufn | afn = Filename with optional disk, user number.

  |  = Or.


*****************************************************************
*								*
*		Command Prefixes				*
*								*
*****************************************************************

 [dsk]:	= Disk drive w/ optional user number for afn's or ufn's.
	  Eg.   b: or b1:

 !	= Negate sense of mode.  Used with d, e, f, t or u command.




*****************************************************************
*								*
*		Commands					*
*								*
*****************************************************************
 
 Note:	All afn (wild card filenames) screw up capture buffer.
	Make sure files closed or saved before use.


 a1:	= Change to disk a, user 1.

 bm	= Set baud rate to m.  Eg. b450.

 break  = Send a break.  May abbreviate br.

 bye	= Dump call (drop DTR).

 call name = dial call using yamphone.t.  May abbreviate name.

 chat	= Chat kbd to kbd.

 check afn = 'chek" checksum and character count.

 close	= Close files.  Dump capture buffer if receive file open.

 crck afn = Crck specified files.

 dir	= Directory listing.

 dirr	= Directory with each file size, tot nr files, tot xmsn time.

 e{mode[s]}	= Enable  modes in term function.  (- = e)

 d{mode[s]}	= Disable modes in term function.

 f[modes] ufn	= Send file while in term function.

 flip {ans | org} = Change modem to answer or orginate.

 h | ?	= Help.  Display this file yamhelp.t.

 i	= Init YAM to default values.  Does not reset disk.

 k	= Kill capture buffer data.

 l	= Link 2 ports.  Exit with ^e.

 type afn = Type file(s) with file length and xmsn time.  ^x aborts.

 list afn = Same as above except ^c does cp/m warm boot.

 mn	= Set modem data port to n in decimal.

 o[ff]	= Hang up modem, return to command mode.  Return to cp/m if off.

 pxm	= Set parameter to value m.

 reset	= Dump capture buff, close file if open, reset cp/m disks.

 replot m = Redisplay last m modem lines.

 rewind	= Reset buffers.

 u	= Upchuck.

 r[options] [file]	= Receive files.  Details below.

 s[options] [file]	= Send files.     Details below.

 s	= Status display.

 sum aft = unix sum of afn.

 t[c][mode] [file] = Term function.  c=close files. ^e=exit.  See below.

 w	= Wrt buff to file if open.

 wc afn = word count of afn.

 x	= eXit to cp/m.

 \ | ;	= Cmmd line delimiter for multiple cmmds on line.

 *	= Send the rest of this line direct to modem.





*****************************************************************
*								*
*		pxm Command Parameters				*
*								*
*****************************************************************

 pxm	= Set parameter to value m.


 cn	= Cislen set to n.  Default 256.  Max 2048.
 gc	= Gochar set to c.  Default lf.
 ec	= Exitchar set to c.  Default ^e.
 ln	= Low set to n.  XOFF sent and file saved when buffer < Low.
 wn	= Waitnum set to n.  Default 1.
 tm	= Throttle set to m.  Default approx 80 wpm.
 pm	= Pause set to m.  Timeout after XOFF, p and w modes.




*****************************************************************
*								*
*		Term Command					*
*								*
*****************************************************************

 t[c][modes] [ufn] = Term cmmd with optional modes and file capture.


 Note:	Dialog may be saved on disk AFTER term conversation
	by command sequence:  t ufn \ ^e \ close


 Modes:	Term modes are set by e(nable),d(isable) or f(ile sender) command.

 c	= Close capture buffer immediately to already existing filename.

 !	= Negate sense of following mode.
 2	= Enable Compuserve A protocol.
 a	= Keyboard cr sent as crlf.
 b	= Binary (8 bit) transmission.
 d	= Enb/dis dumping of captured text if squelch mode, else enb dumping.
 e	= Echo characters.
 f	= Full duplex.
 g	= Go send file in term function.  Equiv to XON.
 h	= Half duplex.
 i	= Image (8 bit) data dumping.  Overrides t | z mode.
 l	= List device on.  Printer is separately buffered.
 n	= Newline (lf) sent only when xmit.  Store rcvd lf as crlf on disk.
 o	= Onetrip.  Exit back to cp/m before next prompt.
 p	= Pause after cr sent until remote echo rcvd.  Timeout if none.
 r	= Return (cr) only sent at end of each line.
 s	= Squelch dumping of captured data with ^t, unsquelch with ^r.
 t	= Throttle to 50 wpm.
 v	= View control chars as ^char and parity set chars as ~char.
 w	= Wait for Gochar (default = lf) after sending cr.  Timeout if none.
 x	= Exit from term when EOF encountered on transmitted file.
 z	= Close file upon ^z while dumping in capture mode.  Else ignore ^z.




*****************************************************************
*								*
*		Keyboarded characters in Term			*
*								*
*****************************************************************

 ^@	= Break char sent.
 ^e	= Exit to command mode.  Quick ^e^e sends one ^e.
 ^f	= Send answerback to remote.
 ^s	= Stop file xmsn.
 ^q	= Resume file xmsn stopped by ^s.
 ^v	= Replot last 24 lines.  Quick ^v^v sends one ^v.




*****************************************************************
*								*
*		Send or Receive File Command			*
*								*
*****************************************************************

 r | s[options] [file] = Receive or Send files.  Options below.


 Notes:
	Options MUST be reset each time s | r command used.

	Protocol compatable with Christenson (Modem7, etc)
		in single file, single sector transfers, cksum or crc.
		Do NOT use batch or 1K block modes with Modem7.

	Usage examples: rcvyt fn.ft, st fn.ft


 b	= Batch. Not compatable with modem7.
		Do not use filename (sender supplies) in r cmmd.
 c	= Crc xfr request to sender.
 k	= Use 1K blocks.
 q	= Quiet mode.
 t	= Term mode after xfr.
 v	= View data.
 y	= Yes, ok to cream old file.




*****************************************************************
*								*
*		Replot Commands					*
*								*
*****************************************************************

 b	= Beginning of buff.
 k	= Kill buffer contents.
 v | bs	= View previous page.  (bs = backspace).
 space	= Next pag
 /search-string<cr> = search buffer from current loc for string
 p	= Backup 1 line.
 n	= search for next occurrence of search string
 lf	= Advance 1 page.
 x	= Display rest of buff, exit.
 z	= Kill rest of buff.
