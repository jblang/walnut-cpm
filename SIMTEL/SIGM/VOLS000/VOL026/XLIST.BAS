	REM	LIST
5 	INPUT "FILENAME: ";FILENAME$
	COUNTER=0
	FILE	FILENAME$
 
10	REM
 
	READ #1; LAST$, FIRST$, ADDRESS$, CITY$,ZIP$,AREA$,TEL$
	IF LAST$="END" THEN 20
	COUNTER=COUNTER+1
	PRINT LAST$;"/";FIRST$;TAB(22);ADDRESS$;TAB(42);CITY$;".,";\Z
		ZIP$;TAB(68);TEL$

	GOTO 10

20	REM
	PRINT:PRINT "END OF LIST"
	PRINT COUNTER, "NAMES":PRINT

	END
C> �C!] ~#� ʙB�CB>.�C:,D��:h ʭB�ʿB�0�C>$�C>$�C��B!e ~#� ��B�C��B>"�C�!C!�C��B�C����B��B!�C��B�  ~���C#��B