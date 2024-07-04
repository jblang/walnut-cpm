	; ============================================================
	; File: SORTORDR.ASM - Harvey Moran 2/26/84
	; ============================================================
	; Use the following instructions to generate
	; the collating sequence file for SSORT.COM
	; 
	; ASM SORTORDR.ddZ
	; LOAD SORTORDR
	; REN SSORT.OVL=SORTORDR.COM
	;
	; ============================================================
	; ============================================================
	; Collating Sequences
	; Number	Description
	; ------	------------
	; 0		REVerse Lexicographical
	; 1		ASCII
	; 2		REVerse ASCII
	; ============================================================
	;
	org	100h
	;
IGNORE	equ	255
X	equ	IGNORE		; synonym
	;
	; REVerse Lexicographical order collating sequence
	;
	db	0,X,X,X,X,X,X,X		; ^@^A^B^C^D^E^F^G
	db	X,X,X,X,X,X,X,X		; ^H^I^J^K^L^M^N^O
	db	X,X,X,X,X,X,X,X		; ^P^Q^R^S^T^U^V^W
	db	X,X,X,X,X,X,X,X		; ^X^Y^Z^[^\^]^^^_
	db	1,X,X,X,X,X,X,X		; <sp><EXCLAIM>"#$%&'
	db	X,X,X,X,X,X,X,X		; ()*+,-./
	db	63,62,61,60,59,58,57,56	; 01234567
	db	55,54,X,X,X,X,X,X	; 89:;<=>?
	db	X,53,51,49,47,45,43,41	; @ABCDEFG
	db	39,37,35,33,31,29,27,25	; HIJKLMNO
	db	23,21,19,17,15,13,11,9	; PQRSTUVW
	db	7,5,3,X,X,X,X,X		; XYZ[\]^_
	db	X,52,50,48,46,44,42,40	; `abcdefg
	db	38,36,34,32,30,28,26,24	; hijklmno
	db	22,20,18,16,14,12,10,8	; pqrstuvw
	db	6,4,2,X,X,X,X,X		; xyz{|}~<del>
	; Msb set byte indices
	db	X,X,X,X,X,X,X,X		; ^@^A^B^C^D^E^F^G
	db	X,X,X,X,X,X,X,X		; ^H^I^J^K^L^M^N^O
	db	X,X,X,X,X,X,X,X		; ^P^Q^R^S^T^U^V^W
	db	X,X,X,X,X,X,X,X		; ^X^Y^Z^[^\^]^^^_
	db	X,X,X,X,X,X,X,X		; <sp><EXCLAIM>"#$%&'
	db	X,X,X,X,X,X,X,X		; ()*+,-./
	db	X,X,X,X,X,X,X,X		; 01234567
	db	X,X,X,X,X,X,X,X		; 89:;<=>?
	db	X,X,X,X,X,X,X,X		; @ABCDEFG
	db	X,X,X,X,X,X,X,X		; HIJKLMNO
	db	X,X,X,X,X,X,X,X		; PQRSTUVW
	db	X,X,X,X,X,X,X,X		; XYZ[\]^_
	db	X,X,X,X,X,X,X,X		; `abcdefg
	db	X,X,X,X,X,X,X,X		; hijklmno
	db	X,X,X,X,X,X,X,X		; pqrstuvw
	db	X,X,X,X,X,X,X,X		; xyz{|}~<del>
	;
	;
	; ASCII collating sequence
	;
	db	  0	;  00 ^@ -- DON'T TOUCH -- so C can find end of string
	db	  1	;  01 ^A
	db	  2	;  02 ^B
	db	  3	;  03 ^C
	db	  4	;  04 ^D
	db	  5	;  05 ^E
	db	  6	;  06 ^F
	db	  7	;  07 ^G
	db	  8	;  08 ^H
	db	  9	;  09 ^I (tab)
	db	 10	;  0A ^J (linefeed)
	db	 11	;  0B ^K
	db	 12	;  0C ^L (formfeed)
	db	 13	;  0D ^M (carriage return)
	db	 14	;  0E ^N
	db	 15	;  0F ^O
	db	 16	;  10 ^P
	db	 17	;  11 ^Q
	db	 18	;  12 ^R
	db	 19	;  13 ^S
	db	 20	;  14 ^T
	db	 21	;  15 ^U
	db	 22	;  16 ^V
	db	 23	;  17 ^W
	db	 24	;  18 ^X
	db	 25	;  19 ^Y
	db	 26	;  1A ^Z
	db	 27	;  1B ^[ (ESCape)
	db	 28	;  1C ^\
	db	 29	;  1D ^]
	db	 30	;  1E ^^
	db	 31	;  1F ^_
	db	 32	;  20 (space)
	db	 33	;  21 !
	db	 34	;  22 "
	db	 35	;  23 #
	db	 36	;  24 $
	db	 37	;  25 %
	db	 38	;  26 &
	db	 39	;  27 ' (single quote)
	db	 40	;  28 (
	db	 41	;  29 )
	db	 42	;  2A *
	db	 43	;  2B +
	db	 44	;  2C , (comma)
	db	 45	;  2D -
	db	 46	;  2E .
	db	 47	;  2F /
	db	 48	;  30 0
	db	 49	;  31 1
	db	 50	;  32 2
	db	 51	;  33 3
	db	 52	;  34 4
	db	 53	;  35 5
	db	 54	;  36 6
	db	 55	;  37 7
	db	 56	;  38 8
	db	 57	;  39 9
	db	 58	;  3A :
	db	 59	;  3B ;
	db	 60	;  3C <
	db	 61	;  3D =
	db	 62	;  3E >
	db	 63	;  3F ?
	db	 64	;  40 @
	db	 65	;  41 A
	db	 66	;  42 B
	db	 67	;  43 C
	db	 68	;  44 D
	db	 69	;  45 E
	db	 70	;  46 F
	db	 71	;  47 G
	db	 72	;  48 H
	db	 73	;  49 I
	db	 74	;  4A J
	db	 75	;  4B K
	db	 76	;  4C L
	db	 77	;  4D M
	db	 78	;  4E N
	db	 79	;  4F O
	db	 80	;  50 P
	db	 81	;  51 Q
	db	 82	;  52 R
	db	 83	;  53 S
	db	 84	;  54 T
	db	 85	;  55 U
	db	 86	;  56 V
	db	 87	;  57 W
	db	 88	;  58 X
	db	 89	;  59 Y
	db	 90	;  5A Z
	db	 91	;  5B [
	db	 92	;  5C \
	db	 93	;  5D ]
	db	 94	;  5E ^
	db	 95	;  5F _ (underscore)
	db	 96	;  60   (back quote)
	db	 97	;  61 a
	db	 98	;  62 b
	db	 99	;  63 c
	db	100	;  64 d
	db	101	;  65 e
	db	102	;  66 f
	db	103	;  67 g
	db	104	;  68 h
	db	105	;  69 i
	db	106	;  6A j
	db	107	;  6B k
	db	108	;  6C l
	db	109	;  6D m
	db	110	;  6E n
	db	111	;  6F o
	db	112	;  70 p
	db	113	;  71 q
	db	114	;  72 r
	db	115	;  73 s
	db	116	;  74 t
	db	117	;  75 u
	db	118	;  76 v
	db	119	;  77 w
	db	120	;  78 x
	db	121	;  79 y
	db	122	;  7A z
	db	123	;  7B {
	db	124	;  7C |
	db	125	;  7D }
	db	126	;  7E ~
	db	127	;  7F
	db	128	;  80
	db	129	;  81
	db	130	;  82
	db	131	;  83
	db	132	;  84
	db	133	;  85
	db	134	;  86
	db	135	;  87
	db	136	;  88
	db	137	;  89
	db	137	;  8A
	db	139	;  8B
	db	140	;  8C
	db	141	;  8D
	db	142	;  8E
	db	143	;  8F
	db	144	;  90
	db	145	;  91
	db	146	;  92
	db	147	;  93
	db	148	;  94
	db	149	;  95
	db	150	;  96
	db	151	;  97
	db	152	;  98
	db	153	;  99
	db	154	;  9A
	db	155	;  9B
	db	156	;  9C
	db	157	;  9D
	db	158	;  9E
	db	159	;  9F
	db	160	;  A0
	db	161	;  A1
	db	162	;  A2
	db	163	;  A3
	db	164	;  A4
	db	165	;  A5
	db	166	;  A6
	db	167	;  A7
	db	168	;  A8
	db	169	;  A9
	db	170	;  AA
	db	171	;  AB
	db	172	;  AC
	db	173	;  AD
	db	174	;  AE
	db	175	;  AF
	db	176	;  B0
	db	177	;  B1
	db	178	;  B2
	db	179	;  B3
	db	180	;  B4
	db	181	;  B5
	db	182	;  B6
	db	183	;  B7
	db	184	;  B8
	db	185	;  B9
	db	186	;  BA
	db	187	;  BB
	db	188	;  BC
	db	189	;  BD
	db	190	;  BE
	db	191	;  BF
	db	192	;  C0
	db	193	;  C1
	db	194	;  C2
	db	195	;  C3
	db	196	;  C4
	db	197	;  C5
	db	198	;  C6
	db	199	;  C7
	db	200	;  C8
	db	201	;  C9
	db	202	;  CA
	db	203	;  CB
	db	204	;  CC
	db	205	;  CD
	db	206	;  CE
	db	207	;  CF
	db	208	;  D0
	db	209	;  D1
	db	210	;  D2
	db	211	;  D3
	db	212	;  D4
	db	213	;  D5
	db	214	;  D6
	db	215	;  D7
	db	216	;  D8
	db	217	;  D9
	db	218	;  DA
	db	219	;  DB
	db	220	;  DC
	db	221	;  DD
	db	222	;  DE
	db	223	;  DF
	db	224	;  E0
	db	225	;  E1
	db	226	;  E2
	db	227	;  E3
	db	228	;  E4
	db	229	;  E5
	db	230	;  E6
	db	231	;  E7
	db	232	;  E8
	db	233	;  E9
	db	234	;  EA
	db	235	;  EB
	db	236	;  EC
	db	237	;  ED
	db	238	;  EE
	db	239	;  EF
	db	240	;  F0
	db	241	;  F1
	db	242	;  F2
	db	243	;  F3
	db	244	;  F4
	db	245	;  F5
	db	246	;  F6
	db	247	;  F7
	db	248	;  F8
	db	249	;  F9
	db	250	;  FA
	db	251	;  FB
	db	252	;  FC
	db	253	;  FD
	db	254	;  FE
	db	IGNORE	;  FF
	;
	; Reverse ASCII collating sequence
	;
	db	  0	;  00 ^@ -- DON'T TOUCH -- so C can find end of string
	db	127	;  01 ^A
	db	126	;  02 ^B
	db	125	;  03 ^C
	db	124	;  04 ^D
	db	123	;  05 ^E
	db	122	;  06 ^F
	db	121	;  07 ^G
	db	120	;  08 ^H
	db	119	;  09 ^I (tab)
	db	118	;  0A ^J (linefeed)
	db	117	;  0B ^K
	db	116	;  0C ^L (formfeed)
	db	115	;  0D ^M (carriage return)
	db	114	;  0E ^N
	db	113	;  0F ^O
	db	112	;  10 ^P
	db	111	;  11 ^Q
	db	110	;  12 ^R
	db	109	;  13 ^S
	db	108	;  14 ^T
	db	107	;  15 ^U
	db	106	;  16 ^V
	db	105	;  17 ^W
	db	104	;  18 ^X
	db	103	;  19 ^Y
	db	102	;  1A ^Z
	db	101	;  1B ^[ (ESCape)
	db	100	;  1C ^\
	db	 99	;  1D ^]
	db	 98	;  1E ^^
	db	 97	;  1F ^_
	db	 96	;  20 (space)
	db	 95	;  21 !
	db	 94	;  22 "
	db	 93	;  23 #
	db	 92	;  24 $
	db	 91	;  25 %
	db	 90	;  26 &
	db	 89	;  27 ' (single quote)
	db	 88	;  28 (
	db	 87	;  29 )
	db	 86	;  2A *
	db	 85	;  2B +
	db	 84	;  2C , (comma)
	db	 83	;  2D -
	db	 82	;  2E .
	db	 81	;  2F /
	db	 80	;  30 0
	db	 79	;  31 1
	db	 78	;  32 2
	db	 77	;  33 3
	db	 76	;  34 4
	db	 75	;  35 5
	db	 74	;  36 6
	db	 73	;  37 7
	db	 72	;  38 8
	db	 71	;  39 9
	db	 70	;  3A :
	db	 69	;  3B ;
	db	 68	;  3C <
	db	 67	;  3D =
	db	 66	;  3E >
	db	 65	;  3F ?
	db	 64	;  40 @
	db	 63	;  41 A
	db	 62	;  42 B
	db	 61	;  43 C
	db	 60	;  44 D
	db	 59	;  45 E
	db	 58	;  46 F
	db	 57	;  47 G
	db	 56	;  48 H
	db	 55	;  49 I
	db	 54	;  4A J
	db	 53	;  4B K
	db	 52	;  4C L
	db	 51	;  4D M
	db	 50	;  4E N
	db	 49	;  4F O
	db	 48	;  50 P
	db	 47	;  51 Q
	db	 46	;  52 R
	db	 45	;  53 S
	db	 44	;  54 T
	db	 43	;  55 U
	db	 42	;  56 V
	db	 41	;  57 W
	db	 40	;  58 X
	db	 39	;  59 Y
	db	 38	;  5A Z
	db	 37	;  5B [
	db	 36	;  5C \
	db	 35	;  5D ]
	db	 34	;  5E ^
	db	 33	;  5F _ (underscore)
	db	 32	;  60   (back quote)
	db	 31	;  61 a
	db	 30	;  62 b
	db	 29	;  63 c
	db	 28	;  64 d
	db	 27	;  65 e
	db	 26	;  66 f
	db	 25	;  67 g
	db	 24	;  68 h
	db	 23	;  69 i
	db	 22	;  6A j
	db	 21	;  6B k
	db	 20	;  6C l
	db	 19	;  6D m
	db	 18	;  6E n
	db	 17	;  6F o
	db	 16	;  70 p
	db	 15	;  71 q
	db	 14	;  72 r
	db	 13	;  73 s
	db	 12	;  74 t
	db	 11	;  75 u
	db	 10	;  76 v
	db	  9	;  77 w
	db	  8	;  78 x
	db	  7	;  79 y
	db	  6	;  7A z
	db	  5	;  7B {
	db	  4	;  7C |
	db	  3	;  7D }
	db	  2	;  7E ~
	db	  1	;  7F (DELete or RUBout)
	db	IGNORE	;  80
	db	IGNORE	;  81
	db	IGNORE	;  82
	db	IGNORE	;  83
	db	IGNORE	;  84
	db	IGNORE	;  85
	db	IGNORE	;  86
	db	IGNORE	;  87
	db	IGNORE	;  88
	db	IGNORE	;  89
	db	IGNORE	;  8A
	db	IGNORE	;  8B
	db	IGNORE	;  8C
	db	IGNORE	;  8D
	db	IGNORE	;  8E
	db	IGNORE	;  8F
	db	IGNORE	;  90
	db	IGNORE	;  91
	db	IGNORE	;  92
	db	IGNORE	;  93
	db	IGNORE	;  94
	db	IGNORE	;  95
	db	IGNORE	;  96
	db	IGNORE	;  97
	db	IGNORE	;  98
	db	IGNORE	;  99
	db	IGNORE	;  9A
	db	IGNORE	;  9B
	db	IGNORE	;  9C
	db	IGNORE	;  9D
	db	IGNORE	;  9E
	db	IGNORE	;  9F
	db	IGNORE	;  A0
	db	IGNORE	;  A1
	db	IGNORE	;  A2
	db	IGNORE	;  A3
	db	IGNORE	;  A4
	db	IGNORE	;  A5
	db	IGNORE	;  A6
	db	IGNORE	;  A7
	db	IGNORE	;  A8
	db	IGNORE	;  A9
	db	IGNORE	;  AA
	db	IGNORE	;  AB
	db	IGNORE	;  AC
	db	IGNORE	;  AD
	db	IGNORE	;  AE
	db	IGNORE	;  AF
	db	IGNORE	;  B0
	db	IGNORE	;  B1
	db	IGNORE	;  B2
	db	IGNORE	;  B3
	db	IGNORE	;  B4
	db	IGNORE	;  B5
	db	IGNORE	;  B6
	db	IGNORE	;  B7
	db	IGNORE	;  B8
	db	IGNORE	;  B9
	db	IGNORE	;  BA
	db	IGNORE	;  BB
	db	IGNORE	;  BC
	db	IGNORE	;  BD
	db	IGNORE	;  BE
	db	IGNORE	;  BF
	db	IGNORE	;  C0
	db	IGNORE	;  C1
	db	IGNORE	;  C2
	db	IGNORE	;  C3
	db	IGNORE	;  C4
	db	IGNORE	;  C5
	db	IGNORE	;  C6
	db	IGNORE	;  C7
	db	IGNORE	;  C8
	db	IGNORE	;  C9
	db	IGNORE	;  CA
	db	IGNORE	;  CB
	db	IGNORE	;  CC
	db	IGNORE	;  CD
	db	IGNORE	;  CE
	db	IGNORE	;  CF
	db	IGNORE	;  D0
	db	IGNORE	;  D1
	db	IGNORE	;  D2
	db	IGNORE	;  D3
	db	IGNORE	;  D4
	db	IGNORE	;  D5
	db	IGNORE	;  D6
	db	IGNORE	;  D7
	db	IGNORE	;  D8
	db	IGNORE	;  D9
	db	IGNORE	;  DA
	db	IGNORE	;  DB
	db	IGNORE	;  DC
	db	IGNORE	;  DD
	db	IGNORE	;  DE
	db	IGNORE	;  DF
	db	IGNORE	;  E0
	db	IGNORE	;  E1
	db	IGNORE	;  E2
	db	IGNORE	;  E3
	db	IGNORE	;  E4
	db	IGNORE	;  E5
	db	IGNORE	;  E6
	db	IGNORE	;  E7
	db	IGNORE	;  E8
	db	IGNORE	;  E9
	db	IGNORE	;  EA
	db	IGNORE	;  EB
	db	IGNORE	;  EC
	db	IGNORE	;  ED
	db	IGNORE	;  EE
	db	IGNORE	;  EF
	db	IGNORE	;  F0
	db	IGNORE	;  F1
	db	IGNORE	;  F2
	db	IGNORE	;  F3
	db	IGNORE	;  F4
	db	IGNORE	;  F5
	db	IGNORE	;  F6
	db	IGNORE	;  F7
	db	IGNORE	;  F8
	db	IGNORE	;  F9
	db	IGNORE	;  FA
	db	IGNORE	;  FB
	db	IGNORE	;  FC
	db	IGNORE	;  FD
	db	IGNORE	;  FE
	db	IGNORE	;  FF
