1�:] � �!�Ͱ�  !b
Ͱ\ !���2!� ^KW�w�#~�ʿ� �4#��p��� !��!  "�!�"�����t"�!�"�� � � !4N<ʞʤ�� �É!�=������Ɓ_ !] ��!e ͒�t!e ͨ�t\ � <�  �2| 2�2�!  "�!f ~�Q�M�v�M��!�6�� !�����M��O�.�4��M��O�.�(��M��O�;�M��H!�͒�t!�ͨ�t� y�x��w!�
Ͱ�t))MD��My��~!�6 !��� !��] !���e !���!�Ͱ:����!�Ͱ !���!�͢!>�������w#���!Ͱ�t�
���
6#6
#6 � ��.� ��%!�
�!�
Ͱ�t*�|��m�!>͊�m� !�����+~�	�P� �b�P !���!>�*���͊�ʇ~���#�p!�Ͱ!>Ͱ!͢!͢��~�0<w�:�60+â^#�� �~�°�!}
�!�����##^#Vz�������{/7?�7�!����!�5��6�M2�:�2����M��M�lg�:���M:���(=2�:�����1>����:2������D>��==2�:��*�|��e*�+"�*�~#"��! "�!�"�6���� \ � ����� �s~�C�#~�O�#~�M�!�
Ͱ��~�C�#~�M�#~�D�!�
Ͱ��^#V�~��#�\��jʾ��p#���w#���~�_��>	#�}��]��{��[�����s#r������~#�[�%��]�1�V��{�:��}�F�V���y��Vx����!}
��!��]��}ȷ��!��[��{���v��~#���g�v~�\�v�V�\�G~���x�{�L�[��N#�?ʊ�@���ʊGy�a���{���_�ʊ���y�0���:ڊ�A���[ڊ�a���{ڊ��MD*=�*?�*A�i`"=�^#V#"?�"A*=͊�>*?���]�(�!�"?��*=��MD�"A�"?�"=i`��*A�͊�-�MD*C�*E�*G�*I�*K�i`"C"E�^#V#"I"K�"G*G�*C͊ʺ*I�*C͊"C*K"I�y*I���}ʵ�!¢"IÆ*E� MD�"K�"I�"G�"E�"Ci`�The command line
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
PATTERN can begin in any column. Squeezed files
will be searched as well as unsqueezed ones. Use
^C to quit, any other key skips rest of file.
 FYNDE.COM 04/01/84 ICUAP
 -- Bad Pattern -- 
-- Search Terminated --  -- Remainder of File Skipped --
 .COM file disregarded.
 .CMD file disregarded.
  -- Code Table Won't Fit --
  DFilenameEXT                                                                                                                                              [original] : original.xxx
 ------> File xxxxxxxx.xxx
       +             0      lines found
       instances in the entire disk
                                                                                                                                                                                                    