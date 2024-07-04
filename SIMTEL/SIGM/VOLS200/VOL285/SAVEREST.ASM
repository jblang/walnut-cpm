;     Last revision: April 30, 1986 at 12:11

TITLE 'SaveRest for dBASEIII'

;       Placed into the Public Domain by the programs author
;       H.M. Van Tassell

;    To generate .BIN file for for dBaseIII LOAD/CALL    
;       1. MASM saverest
;       2. LINK saverest
;       3. EXE2BIN saverest
;    Use the file saverest.BIN with your dBaseIII program
;       Syntax CALL SaveRest WITH "S" or "R"
;     see demo program SAVEREST.PRG

code_seg segment byte 
	assume	cs:code_seg

saverest proc far
        cld                     ; make sure we auto increment
        mov al,Byte Ptr[bx]     ; get passed dBASEII parameter character
        and al,05Fh             ; make sure it is upper case
        cmp al,'S'              ; if Save screen
        je save_screen          ;    jump to save screen routine
        cmp al,'R'              ; if Restore screen 
        je restore_screen       ;    jump to restore screen routine 
        ret                     ; else return back to dBASEIII
;
save_screen:
        xor al,al               ; first get screen mode and page                                       
        mov ah,15               ; function 15 return mode in AL
        int 10h                 ; and page in BH
        mov Byte Ptr CS:screen_mode,al  ; store em 
        mov Byte Ptr CS:screen_page,bh  ; for future use
        xor al,al               ; now get the current cursor position
        mov ah,3                ; function 3 reads cursor position
        int 10h                 ; returns DH,DL=cursor row,col 
        mov Word Ptr CS:cursor_pos,dx   ; store it
        mov ax,0B000h           ; preload mono buffer segment
        cmp Byte Ptr CS:screen_mode,07h ; is 7 if mono mode
        je save_mono
        mov ax,0B800h           ; opps, it is not mono mode
save_mono:
        mov ds,ax               ; DS:SI must point start of screen memory
        mov si,0
        push cs
        pop es                  ; ES:DI must point to screen buffer        
        mov di,offset CS:screen_buffer
        mov cx,25*80            ; number of words to save        
        rep movsw               ; move the screen memory to the buffer
        ret                     ; and return back to dBASEIII 
;
restore_screen:
        ;
        cmp Byte Ptr CS:screen_mode,0FFh; if the screen mode byte hasn't
        jne saved                       ; changed, we havn't first saved
        ret                             ; a screen, so return to dBASEIII
saved:  mov bh,Byte Ptr CS:screen_page  ; BH = current display page
        mov dx,Word Ptr CS:cursor_pos   ; DH,DL = row,col of current position
        xor al,al               ; first restore prior cursor position
        mov ah,2                ; function 2 sets cursor position with
        int 10h                 ; DH,DL=cursor row,col and BH = page
        mov ax,0B000h           ; preload mono buffer segment
        cmp Byte Ptr CS:screen_mode,07h ; is 7 if mono mode
        je restore_mono
        mov ax,0B800h           ; opps, it is not mono mode
restore_mono:
        mov ES,ax               ; ES:DI must point start of screen memory
        mov di,0
        push cs
        pop ds                  ; DS:SI must point to screen buffer        
        mov si,offset CS:screen_buffer
        mov cx,25*80            ; number of words to restore
        rep movsw               ; move the buffer to the screen memory
        ret                     ; and return back to dBASEIII
;
;   we will put the data area within this code segment
;
screen_mode     db      0FFh    ; screen mode, 7 = mono
screen_page     db      0       ; current page here
cursor_pos      dw      0       ; store cursor position here 
screen_buffer   dw  25*80 DUP(?); local screen buffer storage area
;
saverest endp
code_seg ends
	END 











