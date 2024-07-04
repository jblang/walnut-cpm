;
;      TITLE SETUP
;

address equ    20h     ;why not?
        org    0100h
begin:  mvi    a,0c5h  ;push b to save char for 1st:
        sta    address
        lhld   1
        lxi    d,10    ;offset to console routine addr.
        dad    d
        push   h
        mvi    a,call
        sta    address + 1
        mov    a,m     ; con: here
        sta    address + 2
        inx    h
        mov    a,m
        sta    address + 3
        mvi    a,0c1h  ;pop b for 1st:
        sta    address + 4
        mvi    a,ret   ; soon to go...
        sta    address + 5
        inx    h
        inx    h
        mov    a,m
        sta    address + 6    ;lst: addr. here
        inx    h
        mov    a,m
        sta    address + 7
        pop    h       ; restore bios' console addr.
        lxi    d,address
        mov    m,e
        inx    h
        mov    m,d
        ret
        end   begin
;*****************************************************
;****** DON'T RUN THIS PROGRAM MORE THAN ONCE *********
;****** UNLESS YOU COLD BOOT BETWEEN RUNS.    *********
;******************************************************

