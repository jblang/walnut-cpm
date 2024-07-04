; I2VB-3.ASM  -  Adapts modems with verbose mode to IMP.COM  -	06/01/87
;
;		    (For AVATEX, etc. modems)
;
;
;	  ************************************************
;	  *						 *
;	  *   NOTE:  This version is needed for IMP245,  *
;	  *	     use I2VB-2.ASM for IMP244. 	 *
;	  *						 *
;	  ************************************************
;
; The following routine adds verbose mode to the IMP modem program.  A
; few 300/1200 bps modems (such as the 'AVATEX') have only verbose mode.
; This overlay will allow either verbose or terse modes to be used.  The
; 'VERB' equate chooses between verbose and terse, if you have a modem
; with both modes and wish to try both methods.
;
;
;	  verbose			terse
;	  -------			-----
;	OK		     0	(initial commands were all ok)
;	CONNECT 	     1	300 baud
;	RING		     2	(used only during auto-receive)
;	NO CARRIER	     3	(did not get a modem answer)
;	ERROR		     4	(Invalid command)
;	CONNECT 1200	     5	1200 bps
;
;
; The following overlay can be added after the normal overlay, although
; it makes no difference when it is added, really - assuming the normal
; overlay is set for 1200 bps maximum speed and Hayes protocol, which is
; automatically selected if the Racal-Vadic and Prometheus options are
; both set to "NO".
;
;		A>MLOAD IMP.COM=IMP245.COM,I2RV-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/01/87  Altered to work with IMP245, also dated 01 June 87.  Be sure
;    v3     to use I2VB-2.ASM with IMP244.	- Irv Hoff
;
; 06/17/86  Added a "JMP ABORT" line to improve operation during busy
;    v2     signal reception.			- Irv Hoff
;
; 01/05/86  Verbose overlay for IMP244 modem program.  For 300/1200 bps
;    v1     modems that do not have 'terse' mode, such as AVATEX and a
;	    few others.  (Or for those indivuals who may prefer to use
;	    the verbose mode for some reason.)
;						- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
VERB	EQU	'1'		; '1' for verbose mode
				; '0' for terse mode (if available)
DTR	EQU	0FFH		; 0FFH if need ATH0 to disconnect
				; 0 if you can disconnect with DTR
				; Older Avatex modems do not have DTR
;.....
;
;
; Sets parameters to 1200 bps normal operation with Hayes AT protocol
;
	ORG	0100H
	DS	3		; Skip over JUMP to START
MSPEED:	DB	5		; To initiate 1200 bps
HS2400:	DB	0		; No for 2400 bps maximum
HS1200:	DB	0FFH		; Yes for 1200 bps maximum
RACAL:	DB	0		; No for Racal-Vadic protocol
PROMOMD:DB	0		; No for Prometheus ProModem protocol
;.....
;
;
; Disconnects from the phone line with 'ESC N' in terminal mode or with
; 'DSC' or 'BYE' from the command line.
;
	ORG	011EH
NODTR:	DB	DTR
;.....
;
;
; Allows the initialization routine to select between verbose or terse
;
	ORG	0834H		; Location of '0' for V0 in STRNGA:
	DB	VERB
;.....
;
;
	ORG	08D3H
;
	DB	0E1H,011H,080H,000H,03AH,006H,001H,0B7H,0C2H,0FCH,009H
	DB	0CDH,014H,033H,031H,000H,0D2H,061H,00AH,0CDH,014H
	DB	033H,043H,04FH,04EH,04EH,045H,043H,054H,031H,032H
	DB	030H,030H,000H,0D2H,03FH,00AH,0CDH,014H,033H
	DB	04FH,04EH,04EH,045H,043H,054H,031H,032H,030H,030H
	DB	000H,0D2H,03FH,00AH,0CDH,014H,033H,033H,000H,0D2H
	DB	010H,00AH,0CDH,014H,033H,04EH,04FH,043H,041H,052H
	DB	000H,0D2H,010H,00AH,0CDH,014H,033H,04FH,043H,041H
	DB	052H,000H,0D2H,010H,00AH,0CDH,014H,033H,035H,000H
	DB	0D2H,03FH,00AH,0CDH,014H,033H,043H,04FH,04EH,000H
	DB	0D2H,061H,00AH,0CDH,014H,033H,04FH,04EH,04EH,000H
	DB	0D2H,061H,00AH,0C3H,0FCH,009H,03AH,007H,001H,0B7H
	DB	0C2H,079H,009H,03AH,005H,001H,0B7H,0C2H,0FCH,009H
	DB	0CDH,014H,033H,036H,000H,0D2H,06CH,00AH,0CDH,014H
	DB	033H,037H,000H,0D2H,0DBH,009H,0CDH,014H,033H,038H
	DB	000H,0D2H,0FCH,009H,0CDH,014H,033H,031H,030H,000H
	DB	0D2H,050H,00AH,0C3H,0FCH,009H,0CDH,014H,033H,034H
	DB	033H,000H,0D2H,06CH,00AH,0CDH,014H,033H,036H,030H
	DB	000H,0D2H,0EFH,009H,0CDH,014H,033H,036H,031H,000H
	DB	0D2H,081H,00AH,0C3H,0FCH,009H,000H,000H,054H,000H
;.....
;
;
	END
