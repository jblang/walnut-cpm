
; I2RV-6.ASM Racal-Vadic VA212PA or VA3451 special IMP overlay 06/11/87
;
;
; The Racal-Vadic option  in IMP  supports  the 1200V, 2400V and 2400PA
; autodial models.  The VA212PA and 3451 models require a somewhat dif-
; ferent routine.  Essentially they require a CR after the 'D' for dial
; and two carriage returns after the phone number has been entered, the
; first to enter the number in the modem and the second to initiate the
; actual dialing routine.  In addition, they do use "verbose" mode, not
; terse mode, so it is	necessary to "catch the echo characters" before
; proceeding.
;
; The following overlay can be added after the normal overlay, although
; it makes no difference when it is added, really - assuming the normal
; overlay is set  for 1200 bps maximum	speed and Racal-Vadic protocol.
;
;		A>MLOAD IMP.COM=IMP2xx.COM,I2RV-x.HEX
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
; 06/11/87  Increased the RV3451 abort time after dialing to 60 seconds
;	    as it can only pulse dial and is very slow.  Other changes
;	    to improve autodialing with 3451.
;					- Irv Hoff
;
; 06/01/87  Altered addresses for use with IMP245.  Use I2VB-4.ASM with
;	    IMP244.			- Irv Hoff
;
; 10/27/85  There is enough difference in the VA212PA and VA3451 to add
;	    equates to select between the two.	The 3451 is much slower
;	    to execute commands and needs substantial extra delays.  My
;	    thanks to Bond Shands for  extensive 3451 testing.	I could
;	    do the 212PA testing myself.
;					- Irv Hoff
;
; 09/17/85  Initial version		- Irv Hoff
;
; =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
;
;
YES	EQU	0FFH
NO	EQU	0
;
;
; Choose one of the following
;
RV212	EQU	NO
RV3451	EQU	YES
;.....
;
;
; Sets parameters to 1200 bps normal operation for Racal-Vadic protocol
;
	ORG	0103H
	DB	5		; To initiate 1200 bps
	DB	0		; No for 2400 bps maximum
	DB	0FFH		; Yes for 1200 bps maximum
	DB	0FFH		; Yes for Racal-Vadic protocol
	DB	0		; No for Prometheus ProModem protocol
;.....
;
;
; Add extra CR for use with 212PA or 3451 dialing protocol
;
	ORG	05A9H
	CALL	0848H
;.....
;
;
; Allows pulse dialing for alternate dial systems - until recently, most
; required touch tone dialing.	(See the I2NM-x.ASM phone library over-
; lay for information on activating this feature.)
;
	ORG	06E8H
	JMP	06EEH
;.....
;
;
; Initialize modem, wait for "IM READY" to stop
;
	ORG	0794H
	CALL	018FH
	JMP	0762H
;.....
;
;
; Set up modem for dialing
;
	ORG	07B6H
	LXI	H,0865H
	CALL	018FH
	JMP	0762H
;.....
;
;
; Put modem into terminal mode so it is in a position to accept dialing
; (Each # represents 100 milliseconds delay.  Most can be removed for
; use with the 212PA modem which is significantly faster than the older
; 3451.)
;
	 IF	RV3451
	ORG	07F1H
	DB	'I','##',0DH,'####','E'-40H,0DH,'###','$'
	 ENDIF			; RV3451
;
	 IF	RV212
	ORG	07FBH
	DB	'$'
	 ENDIF			; RV212
;.....
;
;
; Puts modem back into IDLE condition when finished
;
	ORG	0812H
;
	 IF	RV3451
	DB	'##',0DH,'##','I','####',0DH,'$'
	 ENDIF			; RV3451
;
	 IF	RV212
	DB	0DH,'#','I','#',0DH,'$'
	 ENDIF			; RV212
;.....
;
;
	ORG	0848H
;
	 IF	RV212
	MVI	B,0DH
	CALL	018CH
	JMP	0762H
	 ENDIF			; RV212
;
	 IF	RV3451
	LXI	H,0851H
	CALL	018FH
	JMP	0762H		; Now go get the result code
;
	DB	'####',0DH,'$'	; Give the 3451 time to enter the number
	 ENDIF			; RV3451
;.....
;
;
	ORG	0865H
;
	 IF	RV212
	DB	'D','#',0DH,'$'
	 ENDIF			; RV212
;
	 IF	RV3451
	DB	'D','##',0DH,'##','$'
	 ENDIF			; RV3451
;.....
;
;
; Increase time to abort to 60 seconds for the 3451 for pulse dialing
;
	 IF	RV3451
	ORG	08A1H
	DW	600		; For 60 seconds
	 ENDIF			; RV3451
;
;
; In the SMRESULT area, fix for verbose ONLINE instead of terse
;
	ORG	0989H		; Change 'L' to 'O' for ONLINE
	DB	'O',0
;.....
;
;
; In the SMRESULT area, fix for verbose NO DIAL TONE instead of terse
;
	ORG	09A1H		; Change 'E' to 'N' for No Dial tone
	DB	'F',0
	JNC	09F0H		; ABORT
;.....
;
;
; If got an answer, go back to get the ONLINE result
;
	ORG	0939H
	JMP	0899H		; Back to SMRESULT
;.....
;
;			       end
;-----------------------------------------------------------------------
;
	END
