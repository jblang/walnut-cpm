10 GOTO 1000
20 REM
21 GOTO 1010
22 REM COMPUTERS DIE DIT NODIG HEBBEN
23 REM MOETEN OP REGEL 20 HEBBEN STAAN:
24 REM     CLEAR A
25 GOTO 1010
100 PRINT CHR$(26);:RETURN
101 REM 100:VEEG HET SCHERM SCHOON
102 REM    OP APPLE : HOME
103 REM    OP TRS   : CLS
104 REM    OP CBM/PET : PRINTCHR$(147)
105 REM    OP ....  : ....
1000 A=500:GOTO 20
1010 GOTO 2500
1020 READ RE$
1030 IF RE$="***"THEN END
1040 BK=1
1050 IF BK>LEN(RE$)THEN 1020
1060 AK=0
1070 AK=AK+1
1080 IF BK+AK>LEN(RE$)THEN 1100
1090 IF MID$(RE$,BK+AK,1)<>" "THEN 1070
1100 WO$=MID$(RE$,BK,AK)
1110 BK=BK+LEN(WO$)+1
1120 IF PL+LEN(WO$)>=RL THEN GOSUB 1210
1130 IF WO$="&"THEN WO$="":GOSUB 1210:GOTO 1170
1140 IF WO$<>"#"THEN 1170
1150 GOSUB 1210:IF AR<>0 THEN 1150
1160 GOTO 1050
1170 PRINT WO$;
1180 PL=PL+LEN(WO$)+1
1190 IF PL<RL-1 THEN PRINT" ";
1200 GOTO 1050
1210 PRINT
1220 AR=AR+1
1230 IF AR<SH-2 THEN 1290
1240 PRINT
1250 PRINT"  VERVOLG: 'n TOETS en <return>";
1260 INPUT SP$
1270 AR=0
1280 GOSUB 100
1290 PL=0
1300 RETURN
1310 :
2500 GOSUB 100
2510 PRINT"Hoeveel karakters kunnen bij Uw computer"
2520 PRINT"op een regel ? ";
2530 INPUT RL
2540 PRINT:PRINT
2550 PRINT"Hoeveel regels kunnen bij Uw computer"
2560 PRINT"op het scherm ? ";
2570 INPUT SH
2580 GOSUB 100
2590 PL=0:AR=0
2600 GOTO 1020
2610 :
3000 DATA"Hallo HOBBYSCOOPVRIENDEN ! & &"
3010 DATA"& Hier is de uitleg over de nieuwe"
3020 DATA"& &          === BASICODE-2 === & &"
3030 DATA"& Voortaan is dit de standaard die bij de uit te"
3040 DATA"zenden HOBBYSCOOP programma's wordt gebruikt."
3050 DATA"& & Wat betekent dat. & Dat betekent, dat"
3060 DATA"het vanaf nu niet meer nodig is dat U zelf elk"
3070 DATA"door HOBBYSCOOP uitgezonden programma moet"
3080 DATA"aanpassen voordat het op Uw computer zonder"
3090 DATA"fouten werkt. & & Hoe kan dat? # Een voorbeeld:"
3100 DATA"& & De opdracht 'CLEAR-SCREEN' is in elke"
3110 DATA"computer anders. & Daarom zal"
3120 DATA"in BASICODE-2 voortaan elk"
3130 DATA"uitgezonden programma dat op een zeker ogenblik"
3140 DATA"het scherm wil schoonmaken, op die plek de"
3150 DATA"instructie   GOSUB100   bevatten. & & Als U dan"
3160 DATA"op regel 100 een subroutine hebt staan die"
3170 DATA"voor Uw machine het scherm schoonveegt, dan"
3180 DATA"is dus het probleem voor 'clear-screen' vanzelf"
3190 DATA"opgelost. &"
3200 DATA"& Voordat U het uitgezonden BASICODE-2"
3210 DATA"programma gaat laden, moet U wel eerst de"
3220 DATA"benodigde"
3230 DATA"subroutine voor 'CLEAR SCREEN' klaarzetten."
3240 DATA"# Zo zijn er diverse subroutines, die"
3250 DATA"elk een bepaalde nuttige taak kunnen verrichten,"
3260 DATA"en wel allerlei taken die in de diverse gangbare"
3270 DATA"computers verschillende commando's nodig"
3280 DATA"hebben. &"
3290 DATA"& Bijvoorbeeld: & &"
3300 DATA"Zet de cursor op een bepaalde plek, &"
3310 DATA"& Kijk of er een toets is ingedrukt, &"
3320 DATA"& Wacht tot er een toets is ingedrukt, &"
3330 DATA"& Print getallen volgens een opgegeven aantal"
3340 DATA"cijfers voor en/of na de komma &"
3350 DATA"& enzovoort, enzovoort,"
3360 DATA"#"
3370 DATA"Deze subroutines zijn zeer zorgvuldig uitgekozen."
3380 DATA"& De ervaringen na een jaar uitzendingen in"
3390 DATA"BASICODE liggen daar natuurlijk aan"
3400 DATA"ten grondslag."
3410 DATA"& Vrijwel alle eerder uitgezonden programma's"
3420 DATA"zouden met deze nieuwe subroutines zonder"
3430 DATA"enig probleem meteen op Uw computer kunnen"
3440 DATA"werken. & Wat er dan nog over blijft zijn"
3450 DATA"dingen als bijvoorbeeld: & -De tijd opvragen,"
3460 DATA"& -Knipperende teksten, & -Kleur,"
3470 DATA"& -Muziekjes, & -Hiresolution,"
3480 DATA"&   en meer van dat moois."
3490 DATA"# De belangrijkste redenen om hiervoor in"
3500 DATA"BASICODE-2 geen voorziening te treffen zijn:"
3510 DATA"& -1- Het komt te weinig voor,"
3520 DATA"& -2- Er zijn (nog) te weinig computers &"
3530 DATA"  die het kunnen."
3540 DATA"& & Zodra uitbreiding nodig blijkt zal de"
3550 DATA"redaktie van HOBBYSCOOP dat zeker bekijken."
3560 DATA"& Met de nu vastgelegde serie subroutines kunnen"
3570 DATA"we echter beslist een flinke tijd vooruit."
3580 DATA"& & Natuurlijk wilt U precies weten welke"
3590 DATA"subroutines op welke plaats moeten staan.
3600 DATA"& Die informatie komt zo direkt. #"
3610 DATA"Allereerst echter dit: & Voor alle computers"
3620 DATA"waarvoor een BASICODE vertaalprogramma bestaat"
3630 DATA"zal dat programma opnieuw worden uitgezonden."
3640 DATA"& De nieuw uit te zenden versie zal U dan tevens"
3650 DATA"de benodigde subroutines kant en klaar leveren."
3660 DATA"& Het is dus helemaal niet nodig dat U deze"
3670 DATA"nieuwe subroutines zelf gaat zitten bedenken."
3680 DATA"& (Het mag natuurlijk wel) #"
3690 DATA"Het spreekt vanzelf, dat U bij het maken van"
3700 DATA"programma's deze nieuwe standaard dient toe te"
3710 DATA"passen. & Zonder dat zou Uw programma op geen"
3720 DATA"enkele andere machine kunnen werken. &"
3730 DATA"& & De nieuwe standaard zal nog niet meteen"
3740 DATA"van kracht zijn: & eerst moeten de nieuwe"
3750 DATA"lees- en schrijfprogramma's zijn uitgezonden."
3760 DATA"& Dat zal een maand of twee duren, dus vanaf"
3770 DATA"pakweg eind maart zal het zover zijn."
3780 DATA"& & Het juiste moment wopdt tijdig aangekondigd"
3790 DATA"en vanaf dat ogenblik vinden alle verdere"
3800 DATA"uitzendingen plaats volgens het nieuwe BASICODE-2"
3810 DATA"protocol. #"
3820 DATA"Hoe is dat protocol nu precies."
3830 DATA"& & Laad daartoe het tweede deel van dit"
3840 DATA"programma en run het. #"
3850 DATA"***"
5000 REM        HOBBYSCOOP
5010 REM    UITLEG BASICODE-2
5020 REM      (EERSTE DEEL)
5030 REM    VRIJ VAN COPYRIGHT
5040 REM          1983
OBBYSCOOP
5010 REM    UITLEG BASICODE-2
5020 REM      (EERSTE DEEL)
5030 RE