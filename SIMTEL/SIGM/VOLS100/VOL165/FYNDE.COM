1O
:] � �!T���  !s��\ !��X�2�!� ^KW�w�#~���� �4#͓����a~
!�
�X!  "O
!�"Q
�@��t"Q
!�"O
� � �� !�4N<ʞʧ��� �É!�
���  =������Ɓ_ !] �X\ � <�  �2| ~
!t
�X~
!�
�X] !^
�Xe !g
�X!S
�� !m
�Q!  "A!w
��!�
��;������w#��3!�
���t�
��A6#6
#6 � ��Z� !����  *O
|�ʙ�!�
�� !m
�Q�r
+~�	�|� ڎ�|~
!t
�X!�
�*Q
����ʳ#~��!m
��!�
��!�
��!�
���~�0<w�:�60+��^#�� �~����!����  *A|��*A+"A*C~��#"C�! "A!E"C6���� \ � ����� �^#V�~��#������<�@p#�Q�w#�X�~�_�i>	#�}ʅ�]ʅ�{ʍ�[ʍ�a��s#r�À�À��~#�[£Ø�]¯��Ø�{¸Ø�}����Ø�y���x����!����  �!��]��}ȷ��!��[��{������~#������~���������G~��Ex�{���[�jN#�?��@�H��Gy�a�E�{�E�_�����y�0�E�:��A�E�[��a�E�{��EMD*��*��*��i`"��^#V#"��"�*��ʿ*��@�]ʩ�!"��É*���MD�"��"��"�i`��*���ʮÒMD*��*��*��*��*��i`"�"��^#V#"�"��"�*��*���;*��*��� "�*�"���*��@�}�6�!�#"��*�� MD�"��"��"��"��"�i`�The command line
     FYNDE D:FILE.EXT EXPRESSION
will search through all instances of FILE.EXT
(which may be an ambiguous reference) on disk D
to find lines containing EXPRESSION. Such lines
will be presented on the console preceded by a
line number, and classified by file. EXPRESSION
may have the form LABEL!PATTERN or simply the
form PATTERN. Both may contain:
     [p1!p2!...!pn]  alternative strings
     {p1!p2!...!pn}  repeated alternatives
     ? any single character
     @ for any alphanumeric: a-z, A-Z, 0-9
     _ in place of horizontal tab
When a label is present, lines will be numbered
relative to the label.  Example: X{?}:![call!ret]
will list calls and returns relative to labels
like X0100: or X33:. LABEL begins in column 1,
PATTERN can begin in any column.
 FYNDE.COM 12/20/82 ICUAP
 -- Bad Pattern -- 
-- Search Terminated -- dDFilenameEXT  the label.  Example: X{?}:![call!ret]
will list calls and returns relative to labels
like X0100: or X33:. LABEL begins in column 1,
PATTERN can begin in any column.
 FYNDE.COM 12/20/82 ICUAP
 -- Bad Pattern -- 
-- Search Terminated -- dDFilenameEXT  the label.  Example: X{?}:![call!ret]
will list calls and returns relative to labels
like X0100: or X33:. LABEL begins in column 1,
PAT----> File xxxxxxxx.xxx
       +             0      lines found
       instances in the entire disk
                                                                      