;		APBYE	V6.9 (revised 3/30/81)
;	REMOTE CONSOLE PROGRAM FOR CP/M AND MODEM
;
;This program allows modem callers to use your CP/M system
;just as if they were seated at the system console.  Special
;assembly-time options allow limiting the caller's access by
;password and/or access to only a message-service program.
;
;Based on an original program written by Dave Jaffe, January 1979
;Rewritten for PMMI modem by Ward Christensen, February 1979.
;
;MODIFIED FOR DCH MMII
;BY DAVID MORITZ, MARCH 1981
;
;
;PLEASE NOTIFY ME OF ANY MOD-
;IFICATIONS:
;
;        DAVID MORITZ
;         2228 N. SAWYER
;         CGO.,IL. 60647
;
;        312 384-4762
;         (24 HR. MODEM)
;
;Thanks to Bill Precht for the "label + offset" idea allowing
;this program to relocate itself without using DDT to initially
;set it up.
;
;Modifications/fixes: (in reverse order to minimize reading time)
;
;03/30/81 COMBINED APBYE12 WITH
;MODIFIED VERSION OF BYE69.
;
;THANKS TO GORDON BANKS FOR THE
;ADDITION OF 'HIMEM' ROUTINES
;TO PREVENT TRANSIENT PROGRAMS
;FROM OVERWRITING BYE BY CHANGING
;THE JUMP VECTOR IN 6,7 TO BDOS
;TO ALLOW JUMPING AROUND THE
;PROGRAM.
;
;03/20/81 Fixed MOUTPUT so parity bit is stripped before outputting
;	  character to modem.  Corrected 3/18/81 null fix.  Added
;	  additional description to heading of this file.  (KBP)
;
;03/18/81 Add first-ring debounce routine, change PMMI HANGUP
;	  to do break for faster disconnect, fix error in P3TODTR
;	  equate for PMMI, added end-of-program error message to
;	  mark ending address (see note at label DEST). By KBP.
;	  Fix bug that prevented nulls at end of line if DUAL$IO
;	  was true.  By Hank Szyszka.
;
;
;02/17/81 Added check for extraneous control characters in
;	  hardcopy log.  (Formfeed seems to be a common "hit").
;	  Changed local startup test to directly test for carrier
;	  instead of calling CARCK, to avoid 15 second delay.
;	  <BRR>
;
;         Rearranged patch list to "most recent first" order.
;	  Added message for invalid-drive test.
;         Added ANI 7Fh to upper case conversion test so that
;         it's not fooled by bit 7 being set.
;         Added WELUSR equate for user # containing WELCOME file.
;         Removed PTRPORT equate and changed hardcopy logic to
;         work through the BIOS printer driver. <BRR>
;
;01/22/81 Changed carrier detect routine for DC Hayes to wait for
;	  15 seconds after loss of carrier to return. <DAVID KOZINN>
;
;	  if present.   <DAVID KOZINN>
;
;
;09/23/80 Fixed bugs that prevented "bye /a" and "bye /c" from
;	  working properly.  Also repaired several errors in
;	  conditional assembly nesting.  By Ron Fowler
;
;09/20/80 Modified status checking during ring-wait routine to
;	  use cp/m BDOS call, as suggested by Keith Petersen.
;	  This should make the program more portable.  Also
;	  added Bruce Ratoff's update to DCHBYE program (5.5),
;	  that allows the use of bye from non-zero user areas.
;	  By Ron Fowler
;
;09/19/80 Modified COM file load routine to prevent BDOS
;	  overwrite if the COM file won't fit in the TPA
;	  By Ron Fowler
;
;09/19/80 Added new '/' option C, which has the same affect as
;	  /A, except that /C loads the com file after answering
;	  the phone, while /A boots cp/m.  By Ron Fowler
;
;09/19/80 Added conditional assembly to give the operator a
;	  'twit' logout key. Added conditionals for 'message
;	  from operator' and 'system down in 5 minutes' keys.
;	  Added front-panel selection of hard-copy log, remote
;	  'black-out', and password option.  Also, if cpm/2 is
;	  used, a message is printed when an unsupported user
;	  area is entered.  By Ron Fowler and Dave Hardy
;
;09/19/80 Modified to prevent re-load of the com file when
;	  a voice call comes in.  Reset the DMA address back
;	  to 80h after the com file is loaded.  By Ron Fowler
;
;09/16/80 Added conditional assembly to allow automatic
;	  loading of a com file instead of cp/m boot. Also
;	  added decimal usrlog counters as conditional
;	  assembly.  By Ron Fowler
;
;09/15/80 Added conditional assembly for automatic timed
;	  log-out, drive and user number masking, lower
;	  case query at login, and cp/m 2.x.  Thanks to
;	  Bruce Ratoff for the routines (lifted from his
;	  'DCHBYE54.ASM') used to implement these functions
;	  NOTE: in order to implement the timed log-out, it
;	  was necessary to do timing in software loops.
;	  Therefore, a new equate, FASTCLK, has been added
;	  to allow for 4mhz clock speeds. Also added Bruce
;	  Ratoff's overrun/framing error checking when read-
;	  ing the modem port.  By Ron Fowler
;
;07/16/80 Added "/R" command option to allow USRLOG
;	  counters to be reset upon entry.  By Dave Hardy
;
;07/11/80 Added conditional assembly for password and
;	  user log routines, and routines to print USRLOG
;	  information on console after program exit.
;	  By Dave Hardy
;
;07/10/80 Added code to allow auto-answer after first
;	  or second ring for more reliable auto-answer
;	  when using "ringback" option.  By Dave Hardy
;
;06/29/80 Added USRLOG routines to keep track of number
;         OF CALLERS.
;	  By Dave Hardy
;
;
;01/24/80 Added routines to preserve registers when calling
;	  the user's CBIOS.  Added conditional assembly for
;	  callback feature.  Increased stack space to 60.
;	  By Keith Petersen.
;
;09/24/79 Added routines to allow automatic multiple baud
;	  rate selection, exit to CP/M from local console,
;	  echo nr. of nulls selected. By Keith Petersen,
;	  with thanks to Bob Mathias for suggestions.
;
;05/06/79 Added routine to allow "callback" operation so modem
;	  does not answer normal voice calls.  By Robbin Hough
;	  and Keith Petersen, W8SDZ.
;
;------------------------------------------------
;
;This program runs up in high RAM.  It gets there
;by being moved there when 'BYE' is typed.
;
;The program in high RAM does the following:
;
;	1.	Hangs up the phone
;	2.	Awaits ring detect, allows exit
;		to CP/M if local KBD types CTL-C
;	3.	Outputs carrier (see callback routines)
;	4.	Awaits incoming carrier going to step 1
;		if none found in 15 seconds
;	5.	Asks number of nulls (0-9)
;	6.	Types the file "WELCOME" from
;		disk, allowing CTL-C to skip it
;	7.	Asks for a password, allowing
;		5 tried to get it right.
;	8.	When password entered, if used,
;		drops into CP/M.
;	9.	Caller can leave by hanging up,
;		(any time carrier is lost, it
;		waits 15 seconds, then goes
;		back to step 1), or the caller
;		may type the program name (BYE)
;
;------------------------------------------------
;
;System equates
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
CR	EQU	0DH
LF	EQU	0AH
MINUTES	EQU	20*60	;CONSTANT FOR 1 MIN TIME DELAY
;
;Change the following equate to an area in your
;high memory where this program may patch itself in.
;Approximate memory requirements: 2k bytes or more,
;depending upon the options selected.  A marker has
;been placed at the end to deliberately print an error
;message during assembly in order to determine the actual
;ending address of the program.  The error message will
;not affect the assembly.  Make sure you have memory
;available up to the address shown.
;
DEST	EQU	0BE00H	;RUNNING LOCATION OF CODE
RSET    EQU     0DAF0H  ;WHERE CP/MLOADS THE BDOS ADDRESS
JUMP    EQU     0C3H  ;OP-CODE FOR A JMP
;
CONDATA EQU     0E000H
;
;
;You will likely also want to change the password,
;located below at label 'PASSWD', and the messages
;printed at label 'WELCOME' and just above label
;'HANGUP'.
;
;****************************************************
;*	    Option configuration section	    *
;****************************************************
;
PRINTER EQU	FALSE	;WANT TO RETAIN LIST DEVICE?
DUAL$IO EQU	TRUE 	;WANT CONSOLE & MODEM?
CALLBAK EQU	FALSE	;WANT CALLBACK FEATURE?
PWRQD	EQU	FALSE	;WANT TO USE PASSWORD?
USRLOG	EQU	TRUE	;WANT TO COUNT NUMBER OF USERS?
HARDLOG EQU	FALSE	;WANT TO ECHO REMOTE KBD TO PRINTER?
CPM2	EQU	TRUE	;USING CP/M 2.x?
MAXUSR	EQU	3	;SET TO 0 FOR CP/M 1.4
MAXDRV	EQU	3	;HIGHEST DRIVE SUPPORTED
FASTCLK EQU	FALSE	;SET TRUE FOR 4 MHZ CLOCK
TIMEOUT EQU	TRUE	;WANT AUTO LOG-OFF FOR SLEEPY CALLERS?
TOVALUE EQU	3	;THIS IS 3 MINUTES TO AUTO LOGOUT
WELUSR	EQU	0	;USER # THAT WELCOME FILE IS KEPT IN
COMFILE EQU	TRUE 	;WANT TO AUTOBOOT A COM FILE?
COMUSR	EQU	0	;USER # THAT COMFILE IS KEPT IN
DECIMAL EQU	TRUE	;WANT DECIMAL VALUES FOR LOGS?
TRAPLC	EQU	FALSE	;WANT TO TRAP LOWER CASE?
;
;Special keys for special functions
;
FKEYS	EQU	TRUE	;WANT SPECIAL FUNCTION KEYS?
;
;Assign function keys to the following control codes (if used):
;
TWITKEY EQU	'N'-40H ;KEYCODE TO LOG-OUT A CREEP
MSGKEY	EQU	'Q'-40H ;KEYCODE TO PRINT 'MESG FROM OPER:'
SYSDKEY EQU	'O'-40H ;KEYCODE TO PRINT SYS DOWN MSG
;
;
;****************************************************
;*	 End of option configuration section	    *
;****************************************************
;
;
;
;MMII MODEM ADDRESS EQUATES
;
TPORT   EQU     0E0A6H ;CONTROL/STATUS PORT
DPORT	EQU	0E0A7H ;DATA PORT
RPORT	EQU	0E0A5H ;RATE GEN/MODEM STATUS
CPORT	EQU	0E0A5H ;MODEM CONTROL
RPORT1  EQU     0E0A6H  ;STATUS
;
;Switch hook and modem commands, output to TPORT (port 0)
;
P0BYE	EQU	0	;ON HOOK, OR DIALING BREAK
P0ORIG	EQU	8EH	;OFF HOOK, ORIG.
P0ANSW	EQU	8AH	;ANSWER PHONE
P0TSB	EQU	08H	;2 STOP BITS
P0EI	EQU	20H	;ENABLE INTERRUPTS
P0NORM  EQU     15H     ;NORMAL 8 BITS, NO PARITY
P0110   EQU     11H     ;SAME W/2 STOP BITS
;
;Modem status, input on RPORT (port 3)
;
P2RDET  EQU     80H     ;RING DETECT
P2CTS	EQU	04H	;CTS (CARRIER DETECT)
;
;MMII modem status masks
;
P0TBMT	EQU	2	;XMIT BUFF EMPTY
P0DAV	EQU	1	;DATA AVAILABLE
P0RPE	EQU	40H	;REC'D PARITY ERR
P0ORUN	EQU	20H	;OVERRUN
P0FERR	EQU	10H	;FRAMING ERROR
;
;Baud rate divisors
;
B110	EQU	0	;110 BAUD
B300	EQU	1	;300 BAUD
;
;
;
;
;---------------------------------------------------------
;
	ORG	100H
;
;Move modem interface program up to high RAM and jump to it
;
;BUT FIRST, PROTECT BYE BY RESETTING BDOS JUMPS
;
HIMEM   LDA     BDOS+2  ;HAS HIMEM ALREADY BEEN SET?
        CPI     0CCH  ;THIS IS WHAT IS NORMALLY THERE
        JZ      CONT  ;STILL CC, SO CONTINUE
        JMP     MOVEUP  ;ELSE SKIP NEXT BIT
CONT    LHLD    BDOS+1  ;LOAD CURRENT BDOS JUMP
        SHLD    DEST-2  ;PUT IN FRONT OF BYE
        MVI     A,JUMP  ;WRITE A JMP OP-CODE IN FRONT OF THAT
        STA     DEST-3
        LXI     H,DEST-3 ;MOVE THE NEW JUMP-TO ADDRESS..
        SHLD    RSET+1  ;..TO THE RESET VECTOR SETTER
        SHLD    BDOS+1  ;AND TO BDOS JUMP ADDRESS
MOVEUP	LXI	B,PEND-START+1	    ;NUMBER OF BYTES TO MOVE
	LXI	H,DEST+PEND-START+1 ;END OF MOVED CODE
	LXI	D,SOURCE+PEND-START ;END OF SOURCE CODE
;
MVLP	LDAX	D	;GET BYTE
	DCX	H	;BUMP POINTERS
	MOV	M,A	;NEW HOME
	DCX	D
	DCX	B	;BUMP BYTE COUNT
	MOV	A,B	;CHECK IF ZERO
	ORA	C
	JNZ	MVLP	;IF NOT, DO SOME MORE
;
	PUSH	H	;SAVE FOR LATER JUMP
	MVI	A,0C3H	;CLEAR ANY TRAPS SO SYSOP..
	STA	0	;CAN USER "BYE /A"
	XRA	A	;NEXT WARMBOOT TO USR0/DRV A
	STA	4
	MVI	C,14	;MAKE DRIVE A DEFAULT
	MOV	E,A	;LOG-IN DRIVE CP/M FUNCTION
	CALL	BDOS
;
	IF	CPM2	;SET USER 0
	MVI	C,32	;GET/SET USR CP/M FUNCTION
	MVI	E,WELUSR
	CALL	BDOS
	ENDIF		;CPM2
;
	RET		;TO ADRS PUSHED ABOVE
;
;
SOURCE	EQU	$	;BOUNDARY MEMORY MARKER
;
OFFSET	EQU	DEST-SOURCE ;RELOC AMOUNT
;
;-----------------------------------------------;
;	The following code gets moved		;
;	to high RAM located at "DEST",		;
;	    where it is executed.		;
;-----------------------------------------------;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XX   C A U T I O N :  If modifying anything	XX
;XX	in this program from here on:		XX
;XX	A-L-L  labels must be of the form:	XX
;XX	LABEL	EQU	$+OFFSET		XX
;XX	in order that the relocation to high  	XX
;XX	RAM work successfully.  Forgetting to	XX
;XX	specify '$+OFFSET' will cause the pro-	XX
;XX	gram to JMP into whatever is currently	XX
;XX	in low memory, with unpredictable	XX
;XX	results.  Be careful....		XX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;
;If carrier lost, hang up, await ring.
;Otherwise, say goodbye, and hang up
;
START	EQU	$+OFFSET
;
	XRA	A	;GET 0
	STA	LOSTFLG ;SHOW NO CARR. LOST
;
;Don't allow a remote user to do 'BYE /A'
;
;
	LDA	RPORT1	;AS ABOVE, FOR PMMI MODEM
	ANI	P2CTS	;CD DEDUCED FROM CTS
	JZ	GOODBY
;
;
;Check for /A option on command - request to
;go immediately into answer mode
	LXI	H,FCB+1 ;TO OPTION
	MOV	A,M
	CPI	'/'	;OPTION?
	JNZ	HANGUP
;Got an option - validate it
	INX	H	;TO OPTION BYTE
	MOV	A,M	;GET IT
	STA	OPTION	;MIGHT NEED LATER
	CPI	'A'	;ANSWER?
	JZ	ANSWER
;
	IF	COMFILE
	CPI	'C'
	JZ	ANSWER
	ENDIF		;COMFILE
;
	IF	USRLOG	;CHECK FOR RESET OF COUNTERS
	CPI	'R'
	CZ	RESET
	ENDIF		;USRLOG
;
	JMP	HANGUP	;WE KNOW IT'S LOCAL, SO SKIP CALL TO CARCK
;
;No option, or invalid one
;
NOSLASH EQU	$+OFFSET
	CALL	CARCK	;SIGNED OFF W/THIS PROG?
	JC	HANGUP	;NOBODY THERE
;
GOODBY	EQU	$+OFFSET
	CALL	ILPRT	;PRINT THIS MSG:
	DB	CR,LF,'GOOD BYE, CALL AGAIN'
	DB	CR,LF,CR,LF,0
	CALL	UNPATCH ;UNDO BIOS PATCHES
;
;Nobody there, or we are done, so hang up
;
HANGUP	EQU	$+OFFSET
	LXI	SP,STACK ;SET UP LOCAL STACK
	XRA	A	 ;FORCE NEXT WARMBOOT TO USER 0
	STA	4	 ;AND DRIVE A
	MVI	C,14	 ;MAKE DRIVE A DEFAULT
	MOV	E,A
	CALL	BDOS
	MVI	A,' '	 ;DON'T ALLOW OPTIONS..
	STA	OPTION	 ;..AFTER 1 "BYE / <ANYTHING>"
;
	IF	CPM2 AND COMFILE
	MVI	C,32	 ;GET/SET USER CODE
	MVI	E,COMUSR ;LOCATION OF OUR COMFILE
	CALL	BDOS
	ENDIF		 ;CPM2 AND COMFILE
;
	IF	COMFILE
	CALL	LODCOM	;LOAD THE COM FILE
	ENDIF		;COMFILE
;
;
HANGUP2 EQU	$+OFFSET
;
;Clear DTR causing phone to hang up
;
;
	XRA	A	;GET DISCONNECT VALUE
	STA	TPORT	;RESET ORIG/ANSW
	STA	CPORT	;TURN OFF DTR, DO BREAK
;
;
;
	MVI	A,0C3H	;CLEAR ANY TRAPS..
	STA	0	;..LEFT FROM COM FILE
;
;Await ringing
;
RINGWT	EQU	$+OFFSET
;
;Check local keyboard for CTL-C exit request.
;NOTE: Must do input via BDOS because CBIOS patches
;are not done until call comes in.
        LDA     CONDATA
	ANI	7FH	;STRIP PARITY BIT
	CPI	'C'-40H ;CONTROL C?
;
	IF	NOT USRLOG
	JZ	0	;YES, --EXIT-- TO CP/M
	ENDIF		;NOT USRLOG
;
	IF	USRLOG	;PRINT OUT USER INFO
	JZ	PRNLOG
	ENDIF		;USRLOG
;
RINGW2	EQU	$+OFFSET
	LDA	RPORT	;GET THE STATUS
	ANI	P2RDET	;RINGING?
	JNZ	RINGWT	;NO, WAIT
;
;The phone may be ringing.  Wait .1 sec and look
;again to make sure it isn't just relay bounce
	CALL	DELAY	;.1 SEC DELAY FOR DEBOUNCE
	LDA	RPORT	;GET STATUS
	ANI	P2RDET	;STILL RINGING?
	JNZ	RINGWT	;NO, IT WAS RELAY BOUNCE
;
;The phone is definitely ringing, now wait until ring is finished
;
ENDRING EQU	$+OFFSET
	CALL	DELAY	;.1 SEC DELAY FOR DEBOUNCE
	LDA	RPORT	;GET STATUS
	ANI	P2RDET	;STILL RINGING?
	JZ	ENDRING ;WAIT UNTIL RING FINISHED
;
	IF	CALLBAK ;NEXT ROUTINES IMPLEMENT CALLBACK
;
;This routine minimizes the computer's interference
;with normal househole phone use by having computer
;folk dial, let the phone ring once, hang up and 
;then dial again.  When the phone rings only once it
;alerts the computer which then waits for and answers
;any ring which occurs within the next 40 seconds.
;
	MVI	L,45	;DELAY 4.5 SECONDS FOR NEXT RING
;
WAITNX	EQU	$+OFFSET
	CALL	DELAY	;WAIT .1 SECONDS
	DCR	L	;MORE TO GO?
	JNZ	WAITNX	;YES, LOOP
	LDA	RPORT	;GET THE STATUS
	ANI	P2RDET	;RINGING AGAIN?
	JNZ	EXPECT	;NO?...ITS FOR ME!
;
;If second ring, then check for third ring, in case
;caller's phone exchange not synch'ed with computer's
;
ENDRNG2 EQU	$+OFFSET
	LDA	RPORT	;GET THE STATUS
	ANI	P2RDET	;STILL RINGING?
	JZ	ENDRNG2 ;WAIT UNTIL RING FINISHED
	MVI	L,45	;DELAY 4.5 SECONDS FOR NEXT RING
;
WAITNX2 EQU	$+OFFSET
	CALL	DELAY	;WAIT .1 SECONDS
	DCR	L	;MOE TO GO?
	JNZ	WAITNX2	;YES, LOOP
	LDA	RPORT	;GET THE STATUS
	ANI	P2RDET	;RINGING AGAIN?
	JNZ	EXPECT	;NO?...ITS FOR ME!
;
;Call not for computer - wait until ringing done, then reset
;
WAITNR	EQU	$+OFFSET
	MVI	L,100	;WAIT FOR 10 SECS NO RINGING
;
WAITNRL EQU	$+OFFSET
	CALL	DELAY	;DELAY .1 SECONDS
	LDA	RPORT	;GET THE STATUS
	ANI	P2RDET	;STILL RINGING?
	JZ	WAITNR	;YES, WAIT 10 MORE SECONDS
	DCR	L	;NO RING, MAYBE WE'RE DONE
	JNZ	WAITNRL ;NO, LOOP SOME MORE
	ENDIF
;
	IF	CALLBAK AND USRLOG
	LDA	NONUSR	;RECORD AS VOICE CALL
	INR	A	;ADD ONE TO COUNT
	ENDIF		;CALLBAK AND USRLOG
;
	IF	CALLBAK AND USRLOG AND DECIMAL
	DAA		;MAKE DECIMAL
	ENDIF		;CALLBK AND USRLOG AND DECIMAL
;
	IF	CALLBAK AND USRLOG
	STA	NONUSR	;SAVE NEW COUNT
	ENDIF		;CALLBK AND USRLOG
;
	IF	CALLBAK ;CONTINUE WITH CALLBAK ROUTINES
	JMP	HANGUP2	;GO WAIT FOR NEXT CALL
;
EXPECT	EQU	$+OFFSET
	LXI	H,400	;40 SECONDS TO WAIT FOR SECOND CALL
;
RELOOK	EQU	$+OFFSET
	LDA	RPORT	;GET THE STATUS
	ANI	P2RDET	;RINGING AGAIN?
	JZ	ANSWER	;YES, GO ANSWER IT
	CALL	DELAY	;WAIT .1 SECOND
	DCX	H	;ONE LESS COUNT
	MOV	A,H
	ORA	L	;IS COUNT ZERO?
	JNZ	RELOOK	;NO, LOOK SOME MORE
	JMP	HANGUP2	;COUNT DONE, WAIT FOR NEW CALL
;
	ENDIF		;END OF CALLBACK ROUTINES
;
;Setup modem
;
ANSWER	EQU	$+OFFSET
;
	IF	USRLOG	;COUNT # OF LOGON ATTEMPTS
	LDA	OLDUSR	;GET # OF ATTEPMTS
	INR	A	;ADD THIS CALL
	ENDIF		;USRLOG
;
	IF	USRLOG AND DECIMAL
	DAA		;MAKE IT DECIMAL
	ENDIF		;USRLOG AND DECIMAL
;
	IF	USRLOG
	STA	OLDUSR	;SAVE NEW COUNT
	ENDIF		;USRLOG
;
;
        MVI     A,P0ANSW  ;TURN ON DTR
	STA	CPORT	;.. AND SET FILTER VALUE FOR 300 BAUD
        MVI     E,20
ANSWR1  EQU     $+OFFSET
	CALL	DELAY	;GIVE TIME TO TURN ON
        DCR     E
        JNZ     ANSWR1
        MVI     A,P0110
	STA	TPORT	;ANSWER PHONE
	CALL	DELAY	;GIVE TIME FOR ANSWER
        LDA     CONDATA
	LDA	DPORT	;CLEAR MODEM PORT
	LDA	DPORT	;MAKE SURE ITS CLEAR
;Output value allowing modem to hang up on loss of carrier
        CALL    CARCK0
        JC      HANGUP
;Now test input for baud rate
	CALL	PATCH	 ;PATCH JMP TABLE
	CALL	TSTBAUD  ;SEE IF BAUD = 110
	JZ	WELCOME  ;YES, EXIT
	MVI	A,P0NORM ;SET FOR 1 STOP BIT, ETC.
	STA	TPORT
        MVI     A,B300+P0ANSW ;SET DIVISOR
        STA     CPORT    ;.. TO 300 RATE
	CALL	TSTBAUD  ;SEE IF BAUD = 300
	JZ	WELCOME  ;YES, EXIT
	CALL	UNPATCH  ;RESTORE ORIG BIOS JMP TBL
	JMP	ANSWER	 ;TEST MORE - INVALID BAUD RATE
;
;
;Following are the USRLOG routines
;
	IF	USRLOG	 ;INCLUDE RESET FUNCTIONS
RESET	EQU	$+OFFSET ;RESET ALL LOGON COUNTERS
	XRA	A
	ENDIF		 ;USRLOG
;
	IF	USRLOG AND PWRQD
	STA	OLDUSR	;RESET ATTEMPT COUNTER
	ENDIF		;USRLOG AND PWRQD
;
	IF	USRLOG
	STA	NEWUSR	;RESET LOGON COUNTER
	ENDIF		;USRLOG
;
	IF	USRLOG AND CALLBAK
	STA	NONUSR	;RESET VOICE COUNTER
	ENDIF		;USRLOG AND CALLBAK
;
;
	IF	USRLOG
	RET
	ENDIF		;USRLOG
;
PRNLOG	EQU	$+OFFSET
;
	IF	USRLOG AND PWRQD ;PRINT # OF LOGON ATTEMPTS
	MVI	C,PRINTF
	LXI	D,ATMSG
	CALL	BDOS
	LDA	OLDUSR
	CALL	HXOUT
	ENDIF		;USRLOG AND PWRQD
;
	IF	USRLOG	;PRINT # OF LOGONS
	MVI	C,PRINTF
	LXI	D,SUMSG
	CALL	BDOS
	LDA	NEWUSR
	CALL	HXOUT
	ENDIF		;USRLOG
;
	IF	USRLOG AND CALLBAK	;# OF VOICE CALLS
	MVI	C,PRINTF
	LXI	D,VCMSG
	CALL	BDOS
	LDA	NONUSR
	CALL	HXOUT
	ENDIF		;USRLOG AND CALLBAK
;
	IF	USRLOG
	JMP	0	;WARM-BOOT BACK TO CP/M
	ENDIF		;USRLOG
;
	IF	USRLOG AND PWRQD
ATMSG	EQU	$+OFFSET
	DB	LF,CR,'NUMBER OF LOGON ATTEMPTS: $'
	ENDIF		;USRLOG AND PWRQD
;
	IF	USRLOG
SUMSG	EQU	$+OFFSET
	DB	LF,CR,'NUMBER OF LOGONS: $'
	ENDIF		;USRLOG
;
	IF	USRLOG AND CALLBAK
VCMSG	EQU	$+OFFSET
	DB	LF,CR,'NUMBER OF VOICE CALLS: $'
	ENDIF		;USRLOG AND CALLBAK
;
	IF	USRLOG
HXOUT	EQU	$+OFFSET
	MOV	B,A	;SAVE NUMBER
	RAR		;ROTATE RIGHT 4 BITS
	RAR		;TO MAKE AN ASCII DIGIT
	RAR
	RAR
	CALL	ONEOUT	;OUTPUT MSH TO CONSOLE
	MOV	A,B	;GET NUMBER BACK
;
ONEOUT	EQU	$+OFFSET
	ANI	0FH	;GET LSH FOR OUTPUT
	CPI	0AH	;CHECK IF ALPHA
	JC	NOTAL2
	ADI	07H
;
NOTAL2	EQU	$+OFFSET
	ADI	30H
	PUSH	B
	MVI	C,02H
	MOV	E,A	;OUTPUT THE NUMBER
	CALL	BDOS
	POP	B
	RET
	ENDIF		;USRLOG
;
;Welcome to the system
;
WELCOME EQU	$+OFFSET
;
GETNULL EQU	$+OFFSET
	CALL	ILPRT	;PRINT THIS MSG:
	DB	CR,LF
	DB	'HOW MANY NULLS (0-9) DO YOU NEED? ',0
	CALL	MINPUT	;GET VALUE
	MOV	C,A	;TO C FOR MOUTPUT
	CALL	MOUTPUT ;ECHO CHAR
	MOV	A,C	;RESTORE VALUE
	CPI	'0'
	JC	GETNULL ;BAD, RETRY
	CPI	'9'+1
	JNC	GETNULL ;BAD
	SUI	'0'	;MAKE BINARY
	STA	NULLS	;SAVE COUNT
;
	IF	TRAPLC
GETULC	EQU	$+OFFSET
	CALL	ILPRT	;PRINT THIS MSG:
	DB	CR,LF
	DB	'CAN YOUR TERMINAL DISPLAY LOWER CASE? ',0
	MVI	A,20H	;FORCE CASE CONVERSION FOR NOW
	STA	ULCSW
	CALL	MINPUT	;GET Y OR NO
	MOV	C,A
	CALL	MOUTPUT ;ECHO
	MOV	A,C
	CPI	'N'
	JZ	DONEOPT ;WE'RE ALREADY SET UP FOR NO LWR CASE
	CPI	'Y'
	JNZ	GETULC	;WASN'T Y OR N...GO ASK AGAIN
	XRA	A
	STA	ULCSW	;SET FLAG FOR NO CONVERSION
;
DONEOPT EQU	$+OFFSET
	ENDIF		;TRAPLC
;
	CALL	ILPRT
	DB	CR,LF,0
;Print the welcome file
	LXI	H,WELFILN ;SOURCE
	LXI	D,FCB	;DESTINATION
	MVI	B,13	;LENGTH
	CALL	MOVE	;MOVE THE NAME
;Set DMA address to 80h
	LXI	D,80H
	MVI	C,STDMA
	CALL	BDOS
;
	IF	CPM2
;Set user number for welcome file
	MVI	C,32
	MVI	E,WELUSR
	CALL	BDOS
	ENDIF		;CPM2
;
;Open the welcome file
	LXI	D,FCB
	MVI	C,OPEN
	CALL	BDOS
;Did it exist?
	INR	A	;A=> 0 MEANS "NO"
	JZ	PASSINT ;NO WELCOME FILE
;Got a file, type it
	XRA	A	;GET 0
	STA	FCBRNO	;ZERO RECORD #
	LXI	H,100H	;GET INITIAL BUFF POINTER
;
;Type the welcome file
WELTYLP EQU	$+OFFSET
	CALL	RDBYTE	;GET A BYTE
	CPI	1AH	;EOF?
	JZ	PASSINT ;YES, DONE
	MOV	C,A	;SETUP FOR TYPE
	CALL	MOUTPUT ;TYPE THE CHAR
	CALL	MSTAT	;CHECK FOR..
	ORA	A	;CHAR TYPED?
	JZ	WELTYLP ;..NO, LOOP
	CALL	MINPUT	;..YES, GET CHAR
	CPI	'C'-40H ;CTL-C?
	JNZ	WELTYLP ;..NO, LOOP UNTIL EOF
;
;Get the password
;
PASSINT EQU	$+OFFSET
;
;
	IF	PWRQD
	MVI	D,5	;5 TRIES AT PASSWORD
;
PASSINP EQU	$+OFFSET
	CALL	ILPRT
	DB	CR,LF,'ENTER PASSWORD: ',0
	LXI	H,PASSWD ;POINT TO PASSWORD
	MVI	E,0	;NO MISSED LETTERS
	LDA	DPORT	;CLEAR OUT GARBAGE
;
PWMLP	EQU	$+OFFSET
	CALL	MINPUT	;GET A CHAR
	CPI	'U'-40H ;CTL-U?
	JZ	PASSINP ;YES, RE-GET IT
	CPI	60H	;LOWER CASE?
	JC	NOTLC	;NO,
	ANI	5FH	;MAKE UPPER CASE ALPHA
;
NOTLC	EQU	$+OFFSET
	CMP	M	;MATCH PASSWORD?
	JZ	PWMAT	;..YES
	MVI	E,1	;..NO, SHOW MISS
	CPI	CR	;C/R?
	JNZ	PWMLP	;..NO, WAIT FOR C/R
;
;Password didn't match
;
PWNMAT	EQU	$+OFFSET
	CALL	ILPRT
	DB	'++INCORRECT++',CR,LF,0
	DCR	D	;MORE TRIES?
	JNZ	PASSINP ;YES
	JMP	BADPASS ;NO, GO HANG UP
;
;Character matched in password
;
PWMAT	EQU	$+OFFSET
	INX	H	;TO NEXT CHAR
	CPI	CR	;END?
	JNZ	PWMLP	;..NO, LOOP
;End of password.  Any missed chars?
	MOV	A,E	;GET FLAG
	ORA	A
	JNZ	PWNMAT	;NOT RIGHT
;Password correct
	ENDIF		;PWRQD
;
NOPASS	EQU	$+OFFSET
;
	IF	USRLOG	;COUNT # OF SUCCESSFUL LOGONS
	LDA	NEWUSR	;GET LAST VALUE
	INR	A	;INCREMENT IT
	ENDIF		;USRLOG
;
	IF	USRLOG AND DECIMAL
	DAA		;MAKE IT DECIMAL
	ENDIF		;USRLOG AND DECIMAL
;
	IF	USRLOG
	STA	NEWUSR	;SAVE NEW VALUE
        ENDIF           ;USRLOG
;
	CALL	ILPRT
	DB	CR,LF,' ',0	;PUT BOOT-UP MSG HERE
;
	IF	COMFILE AND CPM2
	MVI	C,32
	MVI	E,COMUSR	;SWITCH TO COM FILE USER #
	CALL	BDOS
	ENDIF		;COMFILE AND CPM2
;
	IF	COMFILE
	LDA	OPTION
	CPI	'A'	;SYSOP CAN BYPASS COM FILE BY..
	JZ	0	;..TYPING "BYE /A"
	CPI	'C'	;OPER CAN ALSO GO TO COM..
	JNZ	100H	;..FILE LOAD WITH "BYE /C"
	CALL	ILPRT	;PRINT THIS MESSAGE:'
	DB	'Loading system...',CR,LF,0
	CALL	LODCOM
	JMP	100H	;EVERYONE ELSE GETS COM FILE
	ENDIF		;COMFILE
;
	IF	NOT COMFILE
	JMP	0
	ENDIF		;NOT COMFILE
;
;TSTBAUD attempts to read a LF or CR, returns with
;zero flag if the character read is one of these two.
;
TSTBAUD EQU	$+OFFSET
	CALL	MINPUT	;GET CHARACTER FROM MODEM
	CPI	CR	;IF A CARRIAGE RETURN...
	RZ		;.. RETURN
	CPI	LF	;IF A LINEFEED...
	RET		;RET ZERO FLAG, ELSE NOT ZERO
;
;Loss of connection test
;
CARCK0  EQU     $+OFFSET;INITIAL
        PUSH    D       ;CARRIER
        MVI     E,150   ;DETECT
        JMP     CARCK5  ;ROUTINE
CARCK	EQU	$+OFFSET
        PUSH    D
        MVI     E,150
CARCK1  EQU     $+OFFSET
        LDA     RPORT1
	ANI	P2CTS	;GOT A CARRIER?
	JZ	CARCK2	;YES, GO ON WITH TESTS
	CALL	DELAY	;WAIT .1 SECONDS
        DCR     E       ;COUNT DOWN TIME
        JNZ     CARCK1
        STC
        POP     D
        RET
;
;NOW TEST DRIVE #'S AND (IF CP/M 2.X) USER #'S TO
;insure that maximums are not exceeded.
;
CARCK2	EQU	$+OFFSET
	LDA	4	;CHECK DISK/USER #
	ANI	0FH	;ISOLATE DRIVE
	CPI	MAXDRV	;VALID DRIVE?
	JC	CARCK3	;YES, SKIP THIS JUNK
	LDA	4	;GET WHOLE LOGIN BYTE
	ANI	0F0H	;RETAIN USER # & FORCE DRIVE TO A
	STA	4	;UPDATE LOGIN BYTE
	CALL	ILPRT	;TELL USER WHAT HE DID
	DB	'INVALID DRIVE - RETURNING TO A:',0
	JMP	0	;WARM BOOT
;
CARCK3	EQU	$+OFFSET
;
	IF	CPM2
	LDA	4	;GET LOGIN BYTE
	ANI	0F0H	;ISOLATE USER #
	CPI	MAXUSR*16+1 ;VALID USER #?
	JC	CARCK4	;YES, DON'T CHANGE
	LDA	4	;GET LOGIN BYTE AGAIN
	ANI	0FH	;KEEP DRIVE, ZERO USER
	STA	4	;UPDATE LOGIN BYTE
	CALL	ILPRT	;TELL HIM WHAT HAPPENED
	DB	'++INVALID USER NUMBER - RETURNING TO 0++',0
	JMP	0	;WARM BOOT
	ENDIF		;CPM2
;
CARCK4	EQU	$+OFFSET
	ORA	A
        POP     D
	RET
;
CARCK5  EQU     $+OFFSET
        LDA     DPORT
        LDA     DPORT
        LDA     RPORT1
        LDA     RPORT1
        ANI     P2CTS
        JZ      CARCK2
        CALL    DELAY
        DCR     E
        JNZ     CARCK5
        STC
        POP     D
        RET
;
;.1 sec delay routine
;
DELAY	EQU	$+OFFSET
	PUSH	B
;
	IF	FASTCLK
	LXI	B,16667 ;4 MHZ TIMING CONSTANT
	ENDIF
;
	IF	NOT FASTCLK
	LXI	B,8334	;2 MHZ TIMING CONSTANT
	ENDIF
;
DELAY1	EQU	$+OFFSET
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	DELAY1
	POP	B
	RET
;
;50 ms delay routine
;
KDELAY	EQU	$+OFFSET
	PUSH	B
;
	IF	FASTCLK
	LXI	B,8334
	ENDIF
;
	IF	NOT FASTCLK
	LXI	B,4167
	ENDIF
;
	JMP	DELAY1
;
;Patch in the new JMP table (saving the old)
;
PATCH	EQU	$+OFFSET
	CALL	TBLADDR		;CALC HL= CP/M JMP TABLE
	LXI	D,VCOLDBT	;POINT TO SAVE LOCATION
	MVI	B,18		;ALWAYS SAVE PRINTER VECTOR
	CALL	MOVE		;MOVE IT
;Now move new JMP table to CP/M
	CALL	TBLADDR		;CALC HL=CP/M'S JMP TABLE
	XCHG			;MOVE TO DE
	LXI	H,NEWJTBL	;POINT TO NEW
	CALL	MOVE		;MOVE IT
	RET
;
UNPATCH EQU	$+OFFSET
	CALL	TBLADDR		;HL=CP/M'S JMP TABLE
	XCHG			;MOVE TO DE
	LXI	H,VCOLDBT	;GET SAVED TABLE
	CALL	MOVE		;MOVE ORIG BACK
	RET			
;
;Calculate HL=CP/M's jump table, B=length
;
TBLADDR EQU	$+OFFSET
	LHLD	1	;GET BIOS POINTER
	DCX	H	;..SKIP
	DCX	H	;..TO
	DCX	H	;..COLD BOOT
;
	IF	NOT PRINTER
	MVI	B,18	;BYTES TO MOVE
	ENDIF
;
	IF	PRINTER ;RETAIN LIST DEVICE?
	MVI	B,15	;DON'T MOVE LISTER JUMP
	ENDIF
;
	RET
;
;Move (HL) to (DE), length in (B)
;
MOVE	EQU	$+OFFSET
	MOV	A,M	;GET A BYTE
	STAX	D	;PUT AT NEW HOME
	INX	D	;BUMP POINTERS
	INX	H
	DCR	B	;DEC BYTE COUNT
	JNZ	MOVE	;IF MORE, DO IT
	RET		;IF NOT,RETURN
;
;
;Common routine to check for carrier lost, called from console out
;
CHECK	EQU	$+OFFSET
	CALL	CARCK	;SEE IF CARRIER STILL ON
	RNC		;ALL OK
;
;Carrier is lost.  Type message so local console shows the reason
;
BADPASS EQU	$+OFFSET ;COME HERE ON BAD PASSWORD
	MVI	A,1	;SHOW CARRIER LOST SO
	STA	LOSTFLG ;..WE WON'T CK AGAIN
	LXI	SP,STACK ;ENSURE VALID STACK
	CALL	ILPRT
	DB	CR,LF
	DB	'++CARRIER LOST++'
	DB	CR,LF,'   ',0
	CALL	UNPATCH ;RESTORE ORIG BIOS JMP TBL
	XRA	A	;CLEAR OUT CARRIER..
	STA	LOSTFLG ;..LOST FLAG
	JMP	HANGUP
;
;Readbyte routine - used to read the welcome file
;
RDBYTE	EQU	$+OFFSET
	MOV	A,H	;TIME TO READ?
	ORA	A	;..IF AT 100H
	JZ	NORD	;NO READ REQ'D
;Have to read a sector
	LXI	D,FCB
	MVI	C,READ
	CALL	BDOS
	ORA	A	;OK?
	MVI	A,1AH	;FAKE UP EOF
	RNZ		;RET EOF IF BAD
	LXI	H,80H
;
NORD	EQU	$+OFFSET
	MOV	A,M	;GET CHAR
	INX	H	;TO NEXT
	RET
;
;Keyboard/modem status test routine
;
MSTAT	EQU	$+OFFSET
;
	IF	DUAL$IO ;WANT LOCAL CONSOLE?
	CALL	CONSTAT ;GET LOCAL STATUS
	ORA	A
	RNZ		;RET IF LOCAL CHAR
	ENDIF		;DUAL$IO
;
	LDA	TPORT	;GET STATUS
	ANI	P0DAV	;DATA AVAILABLE?
	RZ		;RETURN IF NOT READY
	LDA	TPORT	;GET STATUS
	ANI	30H	;CHECK FRAMING AND OVERRUN BITS
	JZ	MSTAT1	;NO ERRORS...LEGIT CHARACTER
	LDA	DPORT	;SWALLOW CHARACTER (CLEARS PODAV)
	SUB	A	;RETURN FALSE
	RET
MSTAT1	EQU	$+OFFSET
	MVI	A,0FFH	;SHOW READY
	ORA	A
	RET
;
;Modem input function, checks local console first
;
MINPUT	EQU	$+OFFSET
;
	IF	TIMEOUT
	PUSH	H
	LXI	H,TOVALUE*MINUTES ;INITIALIZE TIMEOUT COUNTER
	SHLD	TOCNT
	POP	H
	ENDIF		;TIMEOUT
;
MINPUT1 EQU	$+OFFSET
	LDA	LOSTFLG ;KNOWN LOSS..
	ORA	A	;..OF CARRIER?
	CZ	CHECK	;CARRIER STILL ON?
	CALL	MSTAT	;ANYTHING?
	ORA	A
;
	IF	NOT TIMEOUT
	JZ	MINPUT	;LOOP TILL CHAR RCD
	ENDIF		;NOT TIMEOUT
;
	IF	TIMEOUT
	JNZ	MINPUT2
	CALL	KDELAY	;KILL 50 MS
	PUSH	H
	LHLD	TOCNT	;KNOCK DOWN TIMEOUT COUNTER
	DCX	H
	SHLD	TOCNT
	MOV	A,H
	ORA	L
	POP	H
	JNZ	MINPUT1 ;STILL TIME LEFT..KEEP TRYING
	CALL	ILPRT
	DB	'++INPUT TIMED OUT++',7,7,0
	JMP	NOSLASH
	ENDIF		;TIMEOUT
;
MINPUT2 EQU	$+OFFSET
;
	IF	DUAL$IO ;BOTH LOCAL AND REMOTE
	CALL	CONSTAT ;CHECK LOCAL CONSOLE
	ORA	A	;CHAR?
	JNZ	CONIN	;..YES, READ IT, RET.
	ENDIF
;
;Local console wasn't ready, so read modem
;
	LDA	DPORT	;GET DATA BYTE
	ANI	7FH	;DELETE PARITY
	JZ	MINPUT	;IGNORE NULLS
	IF	HARDLOG
	CPI	20H
	JNC	MINPUT3
	CPI	CR
	JNZ	NOLOG
;
MINPUT3	EQU	$+OFFSET
	CALL	LISTOUT ;ECHO ON PRINTER
	CPI	CR
	JNZ	NOLOG	;CR NEEDS LINEFEED
	MVI	A,LF
	CALL	LISTOUT ;SO SEND IT
	MVI	A,CR	;GET BACK CR
	ENDIF		;END OF HARDLOG
;
NOLOG	EQU	$+OFFSET
;
	CPI	3	;IS IT CONTROL-C?
	RNZ		;NO, PASS IT THRU
	LDA	0	;SEE IF WARM BOOT DISABLED
	CPI	0C3H	;JMP MEANS WARM BOOT OK
	MVI	A,3	;SO RETURN CONTROL-C
	RZ
	XRA	A	;ELSE CONVERT TO NULL
	RET
;
;Modem output function
;
MOUTPUT EQU	$+OFFSET
;
;If we already know carrier is lost, don't check
;for it again or loop trying to output.
	LDA	LOSTFLG ;KNOWN LOSS OF CARRIER?
	ORA	A
	JNZ	SILENT	;AVOID LOOP IN CASE CARRIER LOST
	CALL	CHECK	;CARRIER STILL ON?
	LDA	TPORT	;GET MODEM STATUS
	ANI	P0TBMT	;TRANSMIT BUFFER EMPTY?
	JZ	MOUTPUT ;LOOP IF NOT READY
	MOV	A,C	;GET CHAR
	ANI	7FH	;STRIP PARITY BIT
	IF	TRAPLC
	CPI	60H	;CHECK FOR LOWER CASE
	JC	MOUTP2	;SKIP IF NOT LC
	CPI	7FH	;CHECK FOR RUBOUT
	JZ	MOUTP2
	PUSH	H
	LXI	H,ULCSW ;SUBTRACT EITHER 20H OR 0
	SUB	M
	POP	H
	MOV	C,A	;FORCE ON LOCAL AS WELL AS REMOTE
;
MOUTP2	EQU	$+OFFSET
	ENDIF		;TRAPLC
;
	STA	DPORT	;OUTPUT TO MODEM
;
SILENT	EQU	$+OFFSET
;
	IF	DUAL$IO ;TO LOCAL ALSO?
	PUSH	PSW	;SAVE CHAR
	CALL	CONOUT	;SEND TO REGULAR BIOS
	POP	PSW	;GET CHAR AGAIN
	ENDIF		;DUAL$IO
;
;Check for nulls
	CPI	LF	;TIME FOR NULLS?
	RNZ		;NO, RETURN
;Send nulls if required
	LDA	NULLS	;GET COUNT
	ORA	A	;ANY?
	RZ		;..NO
	PUSH	B
	MOV	B,A	;SAVE COUNT
	MVI	C,0	;0 IS A NULL
;
NULLP	EQU	$+OFFSET
	CALL	MOUTPUT ;TYPE A NULL
	DCR	B	;MORE?
	JNZ	NULLP	;..YES, LOOP
	POP	B
	MVI	C,LF	;RESTORE LF
	RET
;
;Boot trap - becomes disconnect if JMP at 0 has been altered
;
MBOOT	EQU	$+OFFSET
	LDA	0	;LOOK AT OPCODE
	CPI	0C3H	;IS IT STILL JMP?
	JZ	VWARMBT ;YES, ALLOW IT
	JMP	NOSLASH ;NO, DISCONNECT
;
;Inline print routine
;
ILPRT	EQU	$+OFFSET
	XTHL		;SAVE HL, GET MSG
	PUSH	B	;SAVE BC REGS
;
ILPLP	EQU	$+OFFSET
	MOV	C,M	;GET CHAR
	CALL	MOUTPUT ;OUTPUT IT
	INX	H	;POINT TO NEXT
	MOV	A,M	;TEST
	ORA	A	;..FOR END
	JNZ	ILPLP
	POP	B	;RESTORE BC REGS
	XTHL		;RESTORE HL, RET ADDR
	RET		;RET PAST MSG
;
	IF	PWRQD	;KEEP PASSWORD HERE
;Access password (ends in carriage return)
;
PASSWD	EQU	$+OFFSET
	DB	'HELLO' ;THE PASSWORD ITSELF
	DB	CR	;END OF PASSWORD
;Allow room for bigger password to be patched in
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0
	ENDIF		;PWRQD
;
;Routine to load the COM file
;
	IF	COMFILE
LODCOM	EQU	$+OFFSET
	XRA	A	;INITIALIZE FCB
	STA	COMFCB
	LXI	H,COMFCB+12
	MVI	B,21
;
ZLOOP	EQU	$+OFFSET
	MVI	M,0
	INX	H
	DCR	B
	JNZ	ZLOOP
;
	MVI	C,OPEN	;NOW OPEN THE FILE
	LXI	D,COMFCB
	CALL	BDOS
	INR	A	;SHOULD BE NON-ZERO
	JZ	ABORT	;NO FILE, ABORT
;
;Now load the file
	LHLD	6	;GET TOP OF MEMORY
	LXI	D,-80H	;RECORD LOADS CAN'T START..
	DAD	D	;..ABOVE (BDOS) - 80H
	PUSH	H	;SAVE ON STACK
;
	LXI	D,80H	;TPA-80H
	LXI	B,0	;KEEP A RECORD COUNTER
	PUSH	B	;SAVE COUNTER
	PUSH	D	;AND LOAD ADDRESS
;
GLOOP	EQU	$+OFFSET
	POP	D	;GET TPA ADRS
	LXI	H,80H	;POINT TO NXT ADRS TO READ TO
	DAD	D	;HL HAS THE ADDRESS
	POP	B	;INCREMENT THE COUNTER
;Check for load past top-of-memory
	POP	D	;GET (TOP-OF-MEMORY)
	PUSH	D	;RE-SAVE FOR NEXT TIME
	MOV	A,E	;SUBTRACT: (TOP) - (ADRS)
	SUB	L
	MOV	A,D	;ONLY THE CARRY NEEDED
	SBB	H
	JNC	SIZEOK	;CY= BETTER MOVCPM
	CALL	ERRXIT	;SO TELL THE STORY
	DB	'++PROGRAM AREA TOO SMALL++','$'
;
SIZEOK	EQU	$+OFFSET
	INX	B
	PUSH	B
	PUSH	H	;SAVE TPA ADRS
	XCHG		;ALIGN REGISTERS
	MVI	C,STDMA ;TELL BDOS WHERE TO PUT RECORD
	CALL	BDOS
	LXI	D,COMFCB ;NOW READ THE RECORD
	MVI	C,READ
	CALL	BDOS
	ORA	A
	JZ	GLOOP	;A=0 IF MORE TO READ
	POP	B	;UNJUNK STACK
	POP	B	;THIS IS OUR COUNTER
	POP	H	;MORE JUNK ON STACK
	MOV	A,B	;CHECK FOR ZERO
	ORA	C
	JZ	ABORT	;WE SHOULD HAVE READ SOMETHING
	LXI	D,80H	;WE DID, RESET DMA TO 80H
	MVI	C,STDMA
	CALL	BDOS
	CALL	LOADOK	;PRINT THIS MSG TO CONSOLE:
	DB	'++COM FILE LOADED++',CR,LF,'$'
;
LOADOK	EQU	$+OFFSET
	POP	D
	LDA	OPTION	;SEE IF THIS WAS "BYE /C"
	CPI	'C'	;IF IT WAS THEN..
	RZ		;..DON'T PRINT MESSAGE
	MVI	C,PRINTF
	CALL	BDOS
	RET
;
ABORT	EQU	$+OFFSET
	CALL	ERRXIT
	DB	CR,LF
	DB	'++CANNOT FIND COM FILE++','$'
;
ERRXIT	EQU	$+OFFSET
	POP	D
	MVI	C,PRINTF
	CALL	BDOS	;PRINT THE ABORT MSG
	JMP	0	;WARM BOOT
	ENDIF		;COMFILE
;
;This area is used for vectoring calls to the
;user's CBIOS, but saving the registers first
;in case they are destroyed.
;
CONSTAT EQU	$+OFFSET
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	VCONSTAT
	POP	H
	POP	D
	POP	B
	RET
;
CONIN	EQU	$+OFFSET
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	VCONIN
;
	IF	FKEYS
	CALL	CKFUNC
	ENDIF		;FKEYS
;
	POP	H
	POP	D
	POP	B
	RET
;
CKFUNC	EQU	$+OFFSET
;
;
	IF	FKEYS
	CPI	SYSDKEY
	JZ	SYSDOWN ;TELL CALLER TO LEAVE
	CPI	TWITKEY
	JZ	GOODBY	;MAKE CALLER LEAVE
	CPI	MSGKEY
	RNZ
	CALL	ILPRT	;SEND CALLER A MESSAGE
	DB	'MESSAGE FROM OPERATOR:',0
	MVI	A,' '	;SOMETHING TO RETURN WITH
	RET
;
SYSDOWN EQU	$+OFFSET
	CALL	ILPRT
	DB	'SYSTEM DOWN IN'
	DB	' 5 MINUTES....',0
	MVI	A,' '
	RET
	ENDIF		;FKEYS
;
CONOUT	EQU	$+OFFSET
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	VCONOUT
	POP	H
	POP	D
	POP	B
	RET
;
LISTOUT	EQU	$+OFFSET
	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW
	MOV	C,A
	CALL	VLISTOUT
	POP	PSW
	POP	H
	POP	D
	POP	B
	RET
;
;This is the JMP table which is copied on top
;of the one pointed to by location 1 in CP/M
;
NEWJTBL EQU	$+OFFSET
	JMP	MBOOT	;COLD BOOT
	JMP	MBOOT	;WARM BOOT
	JMP	MSTAT	;MODEM STATUS TEST
	JMP	MINPUT	;MODEM INPUT ROUTINE
	JMP	MOUTPUT ;MODEM OUTPUT ROUTINE
	RET		;DUMMY LIST DEVICE
	NOP
	NOP
;
WELFILN EQU	$+OFFSET
	DB	0,'WELCOME    ',0
;Welcome file name ^^^^^^^^^^^ (must be 11 characters)
;
NULLS	EQU	$+OFFSET
	DB	5
;
COMFCB	EQU	$+OFFSET
	DB	0,'RBBS    COM'
;COM file name	   ^^^^^^^^^^^ (must be 11 characters)
;
PEND	EQU	$+OFFSET ;END OF RELOCATED CODE
;
;These areas are not initialized
;
	DS	21	;REST OF COM FCB
;
ULCSW	EQU	$+OFFSET
	DS	1
;
OPTION	EQU	$+OFFSET
	DS	1
;
TOCNT	EQU	$+OFFSET
	DS	2
;
;Byte to keep track of lost carrier when
;typing "++CARRIER LOST++" so we don't loop
;
LOSTFLG EQU	$+OFFSET
	DS	1
;
;Save the CP/M jump table here
;
VCOLDBT EQU	$+OFFSET
	DS	3
;
VWARMBT EQU	$+OFFSET
	DS	3
;
VCONSTAT EQU	$+OFFSET
	 DS	3
;
VCONIN	 EQU	$+OFFSET
	 DS	3
;
VCONOUT  EQU	$+OFFSET
	 DS	3
;
VLISTOUT EQU	$+OFFSET
	 DS	3
;
;Since these areas are not initialized,
;the following counters will not be changed
;by subsequent loads of this program
;
	IF	USRLOG
OLDUSR	EQU	$+OFFSET
	DS	1
;
NEWUSR	EQU	$+OFFSET
	DS	1
;
NONUSR	EQU	$+OFFSET
	DS	1
	ENDIF		;USRLOG
;
;
	DS	60
STACK	EQU	$+OFFSET ;LOCAL STACK
;
ENDMARK	EQU	$+OFFSET ;! IGNORE ERROR. THIS MARKS END OF PGM
;
;BDOS equates
;
CI	EQU	1
WRCON	EQU	2
DRECTIO EQU	6
PRINTF	EQU	9
CSTS	EQU	11
OPEN	EQU	15
READ	EQU	20
STDMA	EQU	26
BDOS	EQU	5
FCB	EQU	5CH 
FCBRNO	EQU	FCB+32
;
	END
 