file:    BYE96HST.MOD    
subject: changes to BYE510 for use of USR Courier HST 9600 baud modem
date:    88/11/24   
author:  Liv Hinckley, sysop FOG#15/NYOUG (212)489-7370
;
;  This file contains the necessary changes to Irv Hoff's BYE510 
;to use the USR Courier HST 9600 baud modem.  The changes are 
;simple for anyone to implement thanks to the very thoroughly  
;documented and annotated files provided by Mr. Hoff.  Most of the 
;work for higher modem speeds was already done in the release 
;version of BYE510. Here we fill in the details necessary to the 
;use of the HST as submitted to PRACSA RCPM on 87/05/25.
;  I hope that others will extend these mods to take fuller 
advantage ot the HST.  This is only a beginning. 
;
;  FOG#15 uses an Osborne Executive CP/M+ computer with 
;Trantor/Westwind hard drive interfaces.  This version of BYE is 
;still in use on FOG#15 with no known bugs.
;
;
;^^^^^----------------------------------------------------new 5/25/87 lh
; Two new equates in BYE option section
;
HST	EQU	YES		;^^^Yes for USR Courier HST result codes
ARQ	EQU	YES		;^^^ Yes for HST ARQ (15-17) result codes
;---------------------------------------------------------end new
;
;^^^^^-----------------------------------------------------new 5/25/87 lh
; Wasn't in the code but very obvious.. maybe add 19200 also?
;
SET9600:MVI	A,BDCMD5	; Get second byte of command
	PUSH	PSW		; ..store it
	MVI	A,B9600		; Load rate
;--------------------------------------------------------end new
;
;^^^^^----------------------------------------------------NEW 5/25/87 LH
; Add new recognition for the extended codes.
;  Most users would use ARQ, but might this not cause trouble
;    with the other programs?
;
	 IF 	B5IM AND HST	; USR Courier HST result codes ENABLED
	CPI	'3'		; 9600 (USR uses 13 if ARQ results
	 ENDIF
;
	 IF	B5IM AND HST AND ARQ
	JZ	SET96		; Yes        are disabled with &A0)
 	CPI	'5'		; 1200/ARQ?  (15,16,17 are default &A1)
	JZ	SET12		; Yes
	CPI	'6'		; 2400/ARQ?
	JZ	SET24		; Yes
	CPI	'7'		; 9600/ARQ?
	JZ	SET96		; Yes
	 ENDIF
; 5/26 just noticed- need to recognize 13 from X1 setting with &A0 in
; case user needs to turn off ARQ codes. Must change. Anchor must be NO
; Should make new displays for result codes 15,16,17.
;perhaps this should also go into KMD.LOG?? haven't checked howto (lh) 
;------------------------------------------------------end new
;
;^^^^^--------------------------------------------------new 5/25/87 lh
SET96	CALL	DLP		; 1 sec delay
	CALL	SET9600		; set port to 9600 bps
	MVI	A,BP9600
	STA	MSPEED		; set speed indicator
	JMP	FINISH
;-----------------------------------------------------end new
;
;^^^^^-------------------------------------------------NEW 5/25/87 lh
; Set HST Extended result codes
	 IF	B5IM AND HST AND (NOT ARQ)
	DB	'&A0'		; Suppress extended codes in case they
	 ENDIF			;  cause trouble.

	 IF	B5IM AND HST AND ARQ
	DB	'&A1'		; This is default, but do it just in case
	 ENDIF			; something changed NRAM settings. 
;
;
;	 IF B5IM AND HST AND PRGRSS	
;	DB	'ATI6'		; try to show diagnostics screen
;	DB	'ATI3'		; show call duration
;	 ENDIF
;   Need display routine for  diagnostics- full page of text, ends with 'OK'
; OR-- put it into the SYS.LOG, or both....
;----------------------------------------------------end new
;
;^^^^^------------------------------------------------new 5/27/87 lh
MSG96	DB	'9600 baud test',CR,LF,0      ; probably not needed
;					      ; since B5IM would be YES
;---------------------------------------------------end new
;
