**    Last revision: June 18, 1986 at 17:56
* list.ag
* this module makes a list of all information in the file
* get a starting  and ending points in file
STOR 'A' TO stletter
@ 17,12 SAY 'Letter of alphabet at which to start report'
@ 17,57 GET stletter PICTURE '!'
READ
STOR 'Z' TO llet
@ 18,12 SAY 'Letter of alphabet at which to end report'
@ 18,57 GET llet PICTURE '!'
READ
CLEA GETS
STOR ASC(llet)+1 TO finish
* goto starting point or next if no find
IF stletter = 'A'
 GO TOP
ELSE
 SEEK stletter
 DO WHIL (EOF() .OR. BOF())
  STOR ASC(stletter) + 1 TO start1
  STOR CHR(start1) TO stletter
  SEEK stletter
 ENDD whil #
ENDI stletter
* initialize variables
STOR 0 TO pageno
STOR .t. TO more2
SET MARGIN TO 10
STOR 'Report of '+CMONTH(DATE())+' '+STR(DAY(DATE()),2)+", "+STR(YEAR(DATE()),4) TO mday
DO WHIL more2
* do page counter etc
 STOR pageno + 1 TO pageno
 STOR 6 TO lineno
 CLEAR
* eject a page and skip down 1 line
IF printer = 'Y'
 SET PRINT ON
 EJEC
ENDIF
 ? '  '
* and write TITLE
 ? '==========================   MAILING LIST   ======================'
 ? ' '
 ? mday + '                              PAGE: '+ STR(pageno,3)
 ? ' '
* now fill up rest of page to 45 lines with names etc
 DO WHIL lineno < 40
* now do a page if not end of file
  IF .NOT. EOF()
   ? '-------------------------------------------------------------------'
   STOR lastname TO lname
   IF ASC(lastname) <= finish
    ? '     ' + TRIM(mr)+' ' + TRIM(fname) +' ' + lastname 
    STOR lineno+1 TO lineno
    IF send = 'Y'
    IF title <> '  '
    ? '     ' + title
    STOR lineno+1 TO lineno
    ENDIF
    IF company1 <> ' '
    ? '     ' + company1
    STOR lineno+1 TO lineno
    ENDIF
    IF company2 <> ' '
    ? '     ' + company2
    STOR lineno+1 TO lineno
    ENDIF
    ? '     ' + TRIM(caddress) + "  " + suite
    ? '     ' + TRIM(ccity) +'  ' + cst + '  ' +czip
    STOR lineno+2 TO lineno
    ELSE
    ? '     ' + TRIM(address) + "  " + apt
    ? '     ' + TRIM(city) +'  '+  st + '  ' +zip
    STOR lineno+2 TO lineno
    ENDIF
    ? '     ' + 'Phones - office: ' + ophone + ' home: ' + phone + ' List: '+cs1+' Code: '+cs2
    SKIP
* if deleted, skip again
    IF DELETE()
     SKIP
    ENDI
   ELSE
    STOR .f. TO more2
    STOR 60 TO lineno
   ENDI RANK(lname)
  ELSE
   STOR .f. TO more2
   STOR 60 TO lineno
  ENDI .NOT. EOF
 ENDD while lineno < 50
ENDD more2
* if it was on turn it off
IF printer = 'Y'
EJEC
ENDIF
SET PRINT OFF
SET ALTERNATE OFF
SET MARGIN TO 0
RETURN




                                                                                                    