;		PAT700V2.ASM

;These patches should be made to MODM700 to obtain the results
;described.  They were previously described as patches to MDM730
;in the file PAT730V8.ASM and were not done in the source code
;for MODM700.  It appears that all of the other patches in PAT730
;were included properly. The object code addresses may have changed
;from MDM730 to MODM700 so use those given below only for MODM700.
;			....    Bob Plouffe   12/28/84

TRUE	 EQU	0FFH
FALSE	 EQU	0

MAXWAIT	 EQU	16		;USE AT LEAST A '5' HERE.
RUB	 EQU	7FH
TERM	 EQU	1618H
MENU	 EQU	32EDH

RUBCON	 EQU	TRUE		;want rubout to go to console?
UNDO$J	 EQU	TRUE		;set to TRUE to restore the 'T'
				;option so that remote end doesn't
				;automatically come up in terminal
				;mode at the end of a file transfer
;*************************************************************
;
;This restores the feature that allows the RUBOUT character to
;go to the console if you desire it.  Code was added in MDM730
;that prevented rubout being sent to console in terminal mode.
;
;In the routine TERML
	ORG	1F0FH
	IF	RUBCON
	DB	0,0,0,0,0	;deletes rubout filter
	ENDIF

	IF	NOT RUBCON
	CPI	RUB
	JZ	TERM
	ENDIF

;***********************************************************
;THIS ONE CONTRIBUTED ANONYMOUSLY AS undo-j.asm AND INCLUDED
;HERE AS AN ADDITIONAL OPTION.
;To undo the 'J' option and restore the 'T' option as it has
;always been. Set UNDO$J to TRUE to enjoy this option.  Irv
;never did change the help screens to describe his 'J' option
;anyhow.  The 'T' option is still the one described there.

;The following code is in the DONETC routine:
	ORG	2AFBH
	IF	UNDO$J
	JNZ	MENU
	ENDIF
	;
	IF	NOT UNDO$J
	JZ	MENU
	ENDIF

; and at the following storage locations near the end of the file.
	ORG	4952H
	IF	UNDO$J
	DB	'T'
	ENDIF
	;
	IF	NOT UNDO$J
	DB	'J'
	ENDIF

	ORG	495FH
	IF	UNDO$J
	DB	'T'
	ENDIF
	;
	IF	NOT UNDO$J
	DB	'J'
	ENDIF

;
;*******************************************************************
;This patch fixes a bug found by Ron Fowler that causes the wrong
;file to be erased in the directory when overwriting existing files
;in batch mode.
;..in the routine at CKCPM2:
	ORG	2238H
	NOP			;These 2 bytes replace 'CPI  0FFH'
	INR	A

;*******************************************************************
;This patch makes the program MUCH more tolerant of network or
;transmission delays such as found in packet switched nets (ARPANET)
;as well as on satellite communication links.  Do not use a value for
;MAXWAIT less than 5 (5 seconds) and even as high as 16 seconds is ok
;which will then tolerate some of the large throttling delays often
;encountered.

	ORG	1B8FH
	MVI	B,MAXWAIT

	ORG	1BF3H
	MVI	B,MAXWAIT

	ORG	1C0CH
	MVI	B,MAXWAIT

	ORG	1CA0H
	MVI	B,MAXWAIT

	ORG	1D03H
	MVI	B,MAXWAIT

	ORG	240AH
	MVI	B,MAXWAIT

	ORG	2413H
	MVI	B,MAXWAIT

	ORG	245EH
	MVI	B,MAXWAIT

	ORG	2477H
	MVI	B,MAXWAIT

	ORG	2496H
	MVI	B,MAXWAIT

;*******************************************************************
	;the
	END
