�]FORMAT VERSION 2.1 COPYRIGHT,1981 NORTH STAR COMPUTERS,INC.�* w <w* ew& w=���͋* ��~���A#~��A>"�>* �w#>'w!��o2�	!��D��!��Q��!��R��!�2���X�  !4�S��!]�N��!4�O�w�>"�>* �w#w����>'�>* �w#w�~2�	#"�	!�o͚��;2�	��02�:�	�@�J:�	����*�;:�	�@�Z:�	��Z_͋�w|͋�  :�	�N��Z�O�;�͋*�	�o��  ��w:�	W	!E �Q���	!O �R��+	!" �D��+	!" �2��+	!" �S���	!� �O���	!� �N���Z%"�	͋!� 6�#����* 0 "�	!�	4F:�	��	!�  ��>
��	*� ��!� 6 #��!R"s
:�	2e
G�����H!�"s
!�	x�����H!@"s
!
Y
͑!	
���\!� >  ��	�͋�w�͋�	
� !�	~�>�#~�`��_�	� �~#��Aڡ��1��1�?�<G�* O~µ怰HG++~���@��:�	�O:�	怱O�
CP/M Diskette Formatter as of Dec 2, 1982.
Initializes Diskettes for use with CP/M.
Supports 96 tpi drives with 2 alternate
formats (2kb & 4kb blocks).  Also supports
a 40 track/side format for Quad drives.
$
Load Diskette in Drive: X,
Strike RETURN <cr> when ready,$

Diskette Successfully Initialized

$

Enter Drive number(1-4): $�
To format as: Octal with 2kb blocks: $�
To format as: Nine-Capacity Diskette: $�
To format as: Quad-Capacity Diskette: $�
To format as:(Alt) Quad-Capacity Diskette: $�
To format as: Double-Density Diskette: $�
To format as: CP/M 2 Double-Density: $
To format as: Single-Density Diskette: $

*** ERROR - Can NOT format Quad-Capacity
*** CPMGEN was told that Drive is NOT Quad$

*** ERROR - BAD DRIVE NUMBER$

*** ERROR - Only N=NINE Format Permitted
since CPMGEN was told drive is N-TYPE$

*** ERROR - N Format cannot be done
since CPMGEN was not told drive is N-TYPE$

Works only with North Star CP/M ver 1.1.0
$
Select one of the format options below:

D = Double-Density Single-Sided = D
2 = DD-SS for old CP/M 2        = 2

Q = Quad-Capacity (35 trks/side)= Q
R = Quad-40 tracks per side     = R

N = Nine-Capacity   (Octal)     = N
O = Octal with 2kb blocks       = O

S = Single-Density              = S
X = eXit - Warm Boot from A:    = X

Enter option letter (D,2 Q,R N,O S,X): $
- Proceeding to Format 35 * Tracks -...
$
- Proceeding to Format 70 * Tracks -...
$
- Proceeding to Format 80 * Tracks -...
$
- Proceeding to Format 160 * Tracks -...
$	             �      QUAD.CAPDOUBLE-DNINE-CAP                                CP/M 2.2    �                                   XXXXXXXX        DISKETTE    �   CPM FROM    �   NORTH *     �   STAR        �   --------    �   -SYSTEM-  �   -TRACKS-  �   BIOS      �   USER      �   CPM CCP 	  �   CPM BDOS  �   --------    �   DIR.SEC1  �   DIR.SEC2  �   DIR.SEC3  �   DIR.SEC4  �   --------    �   CPM DATA    �   DATASEC1  �   DATASEC2  �   DATASEC3  �   DATASEC4� ........    �                                              