;     Last revision: July 1, 1986 at 12:44

;    by: H.M. Van Tassell, Watchung, NJ   

;    To generate .OBJ file for use with Clipper
;       1. MASM CURSOR
;    Thats all except to include the file CURSOR.OBJ in your
;    PLINK86 link list of the .PRG file you are Clippering.
;
;    See the individual public routines for the callin systax   

prog	segment	byte public 'prog'
	public	CursOn, CursOff
	assume	cs:prog
;
;       Syntax: CALL CursOn to turn on cursor
;
Curson proc far
        int     11h
        and     al,10h
        mov     cx,8687h
        jz      around
        mov     cx,8b8ch
around:
        mov     ah,01h
        int     10h
        ret
Curson endp
;        
;       Syntax: CALL CursOff to turn off cursor
;
Cursoff proc far
        mov     ah,01h
        mov     cx,8f8fh
        int     10h
        ret
Cursoff endp
;
prog    ends
	END 




