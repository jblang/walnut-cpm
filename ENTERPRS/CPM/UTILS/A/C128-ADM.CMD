
 ; Lear Siegler ADM31 Aliases for the Commodore 128

 ; Clear to End of Line
CEL			echo t
 ; Clear to End of Screen
CES			echo y
 ; Clear Screen and Home Cursor
CLRHOME		echo :
 ; Half Intensity On
HALFINTON	echo )
 ; Half Intensity Off
HALFINTOFF	echo (
 ; Reverse Letters On
RVSON		echo g4
 ; Blinking Letters On
BLINKON		echo g2
 ; Underlined Letters On
ULINEON 	echo g3
 ; Switch to Alternate Character Set
ALTCHAR		echo g1
 ; Turn off Reversed, Blinking, Underlined,and Alternate Characters 
NORMAL=RVSOFF=BLINKOFF=ULINEOFF echo g0
 ; Insert a Line
INSERTLINE	echo e
 ; Insert a Character
INSERTCHAR	echo q
 ; Delete a Line
DELETELINE	echo r
 ; Delete a Character
DELETECHAR  echo w
 ; Ring System Bell
BELL		echo 

