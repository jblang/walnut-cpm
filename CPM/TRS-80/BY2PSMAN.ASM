;******************************************************************************
;               D. C. HAYES SMARTMODEM 300/1200 'Modem Control'
;                          BY2SMDM.ASM BY Don Brown
;                           version 1.1   04/24/83
;
; These routines may be used along with the more specific modem/usart
; routines commonly found in BYE11.LBR.
;
; These routines are specific to the needs of the Smartmodem 300/1200
; when used with BYEII and are not intended to override or preempt any
; function that is already performed by that software.
;
; This code is intended to be appended just after your own BYEII usart
; code, in BYEII.
;
;******************************************************************************
;
; Modification History (in reverse order):
;
; 07/23/84: Added BYE2FIX from Dave Crane. This fix will
;           reinitialize the Smartmodem in the event of a failure
;           caused by a ring at the same time the modem is being
;	    initialized.				    <Ed Richter>
;
; 07/13/84: Modified and renamed to include the necessary code to allow  
;           use of the Anchor Signalman Mark XII also.      <Ed Richter>     
;
; 07/14/83: Modified the ring count to 2 instead of 3 (for S0=x). Other
;           modems would be timing out just as connection was being made.
;                                                               <pst>
;
; 04/24/83: Moved the smartmodem command bytes to reset the smartmodem
;           register S0, (answer on the nth ring), to the end of the
;           command string. Increase the number of rings stored in S0 from
;           1 to 3. Reduced the number of seconds stored in the S7 register
;           (number of seconds to wait for carrier before hang-up), from
;           30 to 11. Added additional comments. Assigned version 1.1
;                                                      <Don Brown>
;
; To use this code, the BYE2 routines for your usart must be modified:
;           SMODEM   EQU   TRUE      ;True, Hays Smartmodem 300/1200
;                                    ;or Anchor Mark XII
;          After all usart and baud rate instructions have been executed
;          and immediately after dtr has been set logic true, (dtr=on for
;          Smartmodem to receive commands), add the following:
;
;          IF SMODEM
;          CALL SMINIT
;          ENDIF        ;SMODEM
;
; The following hardware configuration is assumed.
;
;          DTR  (Pin 20)    true
;          DCD  (Pin  8)    true
;          RI   (Pin 22)    not true (Mark XII supports true or false)
;
; The following software (BYEII) configuration is assumed.
;         CWAIT    EQU     10
;         CLOSS    EQU      5
;
;         NORING   EQU     TRUE  (Mark XII supports true or false)
; There are no external switches for the Mark XII
;
;
; The following smartmodem default switches are assumed:
;  A. Switches not controlled by software:
;     1=up, 6=up, 7=up, 8=down
;
;  B. Switches controlled by software
;     2=up, 3=down, 4=down, 5=down
;
; Notes:
;     Smartmodem and Anchor will automatically set itself to the speed 
;     of the calling modem, if the speed is 300 or 1200. This relieves 
;     us of the need to set modem speed (still have to check and set the 
;     usart/baud), via software. 110 baud is not supported because the 
;     Smartmodem will not differentiate between 300 and 110 baud. You 
;     need to modify your usart routines to handle only 300/1200 baud.
;
;    BYEII drops DTR in order to hang up the phone. When DTR goes false
;    the Smartmodem will automatically drop the line and go to the local
;    command state. The Anchor Mark XII will not do this and must be reset
;    using software commands and the escape code. Because of this the
;    smartmodem can be "hung-up" if DTR goes true while the phone is 
;    ringing. Consequently it is extremely important that the register (S0)
;    be set to at least 2 and possibly 3 rings, and the command string ATZ
;    be executed immediately after DTR is set.
;
; Commands sent to the Smartmodem:
;    a.  'ATZ'    Attention and reset to default values
;    b.  The meaning of the 2nd command string is as follows:
;        'AT'     Attention
;        'Q1'     No result codes sent
;        'E0'     Do not echo commands
;        'M0'     Speaker off (not Mark XII)
;        'S0=128' Disable escape codes (not Mark XII)
;        'S7=11'  Seconds to wait for carrier (not Mark XII)
;        'S9=6'   Wait 6 seconds after carrier (not Mark XII)
;        'S10=60' Time to wait after carrier loss (not Mark XII)
;        'S0=2'   Answer on 2 rings. (should be last item in command string)
;
;******************************************************************************
;
; Initialize the Smartmodem.
; DTR must be logic true for the smartmodem to receive a command.
; The S0 register should be set to not less than 2 and should be the last
; string in the command.
;...
;
RINGS	EQU	'2'
;
;...
;
SMINIT 	EQU	$+OFFSET
	IF	ANCHOR
	CALL	SMDELAY			;1 second delay for the Mark XII      
	CALL    SMSEND 			;send escape code           
	DB	'+++',0
	CALL	SMDELAY		 	;1 second delay for Mark XII
        CALL    SMSEND
	DB	'ATZS0=0',CR,0		;hang up and no-auto answer
	CALL	SMDELAY			;1 second delay for disconnect
	CALL	SMSEND
	DB	'ATE0Q1S0='		;initialize no echo, no result codes
	DB	RINGS			;and answer on 2nd ring
	DB	CR,0
	CALL	SMDELAY
	ENDIF	;ANCHOR
;...
	IF	NOT ANCHOR
	CALL	SMSEND
	DC	'ATZ',CR,0		;Hayes default reset
	CALL	SMDELAY			;1 second needed by Smartmodem
	CALL	SMDELAY			;1 to stop erratic loads
	CALL	SMSEND
	DB	'ATQ1E0M0S2=128S7=11S9=6S10=60S0='
	DB	RINGS
	DB	CR,0			;end message
	CALL	SMDELAY			;1 second needed by Smartmodem
	ENDIF	;IF NOT ANCHOR
;...
	CALL	SMSEND			;Look for error in S0
	DB	'ATS0?',CR,0
;...
SMCHK	EQU	$+OFFSET
	CALL	SMGET
	CPI	CR
	JZ	SMCHK			;Ignore CR and LF
	CPI	LF
	JZ	SMCHK			;Ignore
	CALL	SMGET			;Skip 2nd zero
	CALL	SMGET			;Look at third digit
	CPI	RINGS			;This better be it
	RZ				;OK
	JMP	SMINIT			;Retry
;...
SMGET	EQU	$+OFFSET
	CALL	MDINST
	CPI	0			;Reply ??
	JNZ	SMRDOK
	LHLD	RDCNT			;RDCNT is designed to keep us
	INX	H			;from hanging in a loop waiting
	SHLD	RDCNT			;for a modem that doesn't 
	XRA	A			;respond
	CMP	H
	JNZ	SMGET
	CMP	L
	JNZ	SMGET
	JMP	SMRDNOK			;Oh, Oh. Modem isn't going to speak
;...
SMRDOK	EQU	$+OFFSET
	CALL	MDINP			;read
;...
SMRDNOK	EQU	$+OFFSET
	PUSH	A
	XRA	A
	STA	RDCNT			;Counter reset
	STA	RDCNT+1
	POP	A
	RET
;
RDCNT	EQU	$+OFFSET
	DB	0,0
;
SMDELAY	EQU	$+OFFSET
	PUSH	B  			;In case it is used
	MVI	B,10
DLP1	EQU	$+OFFSET
	CALL	DELAY
	DCR	B			;Delay 1 second
	JNZ	DLP1
  	POP	B			;Done restore BC
	RET
;
SMSEND	EQU	$+OFFSET
 	XTHL	
	PUSH	B			;Get address of message
SMPLP	EQU	$+OFFSET
	CALL	MDOUTST			;Modem status
	JZ	SMPLP			;Not ready, try again
	MOV	A,M			;Get character
	CALL	MDOUTP			;Send character
	INX	H
	MOV	A,M			;Next character
	ORA	A			;0= All sent
	JNZ	SMPLP			;No get another
	POP	B			;Done restore BC
	XTHL				;Restore HL, get return address
	RET
;
;End of Smartmodem overlay for BYEII
;******************************************************************************
