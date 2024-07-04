
MEXCLS.PAT

	If you'd like MEX to not clear your screen after a "R" or "S"
function, which is handy if the remote has printed the number of blocks
to be sent, you can modify MEX as follows.

		POKE $0DEF 0 <-- To disable clear screen
		POKE $0DEF 1 <-- To enable  clear screen

	Then simply clone mex "CLONE MEX.COM" to save the change!

						-Adam Koczarski
						 Adam's RiBBS PBBS
						 (206) 882-3684
