1�$:] � �!����  !�����\ !N��l !��� ͹!~� �J6S#6Y#6M	l !���6X#6R#6F# ͹!� ^ �6 �#~���� �p#~���� �{#~���� ʆ#~�ʝ� #�6͑H��� <»!���� <��!���� <����!T��!� "�!�"�!  ""!H~��
"H!�����<�w2M!�����!������K!W͹�
!T�����:�  !/��� � !h 6 N� !M4N<ʅʎ�N� ��p!/����=������Ɓ_ !] ��!e �b�V!e �x�V!e ͎�V\ � <�  �2| 2| 2�2�!  "�!f ~�Q�d�v�d��!�6�� !�͹��d��E�.�*��d��E�.���d��E�1�d��>!��b�V!��x�V!e ͎�V�y�x��v!L���V))MDH �dy��}!�6!��!��] !���e ! ��!�����:����!����� !͹!͹!p�����)��w#��!�����V�
���6#6
#6 � ��A� ��5�� !��!������V*|�ʀ�!pͫ� !͹�+~�	�c� �u�c!��!pH�ͫ�ʘ~���#Ã!����!p����!͹!2͹��~�0<w�:�60+ù^#�� �~����!��!H ���##^#Vz�������{/7?�7�!H ���!�5�6�d2�:�2����d��d�lg�:���d:���?=2�:�����H>����Q2������[>��==2�:��*�|��|*�+"�*�~#"��! "�!�"�6���� \ � ����� Ê�*|���*+"*!~#"!��!� "!#"!6����� �� �����~���#���������*�|��*�+"�*��w#"��!� "�!�"����� �� � !�����*��{��R*�6#{��F��� <�!$�~�C�#~�O�#~�M�!����~�C�#~�M�#~�D�!3����~�X�#~�R�#~�F�!j����^#V�~��#�}�͋ʤèp#¹�w#���ͩ�ʩ��w#�_��>	�}���]���{���[�����s#r������~�_�>	#�}�(�]�(�{�0�[�0����s#r��#��#��~#�[�F�;�]�R�w�;�{�[�;�}�g�w�;��;y��wx����!���!��]��}ȷ��!��[��{��͗��~#��͈~�}�w�}�G~���x�{�m�[�
N#�?ʫ�@���ʫGy�a���{���_�ʫ���y�0���:ګ�A���[ګ�a���{ګ��MD*o�*q�*s�i`"o�^#V#"q�"s*oͫ�_*qͨ�]�I�!�5"q��)*o��MD�"s�"q�"oi`��*s�ͫ�N�2MD*u�*w�*y�*{�*}�i`"u"w�^#V#"{"}�"y*y�*uͫ��*{�*uͫ��"u*}"{Ú*{ͨ�}���!��"{ç*w� MD�"}�"{�"y�"w�"ui`�The command line

     FFYNDE [D:]FILE.EXT [E:]KEY.SYM LABEL

will search through all instances of FILE.EXT (which
may be an ambiguous reference) on disk D for lines
containing keywords taken from KEY.SYM (whose disk may
be specified). Any of these keywords may be regular
expressions. Then the whole family of files will be
searched for each line in KEY, whose default extension
is SYM. Results will be shown on the console and placed
in [E:]KEY.XRF. LABEL, a regular expression too, is a
reference for relative line numbers; if it is omitted
lines will be numbered serially in each file. Regular
expressions are formed as follows:
     [p1!p2!...!pn]  alternative strings
     {p1!p2!...!pn}  repeated alternatives
     ? any single character
     @ for any alphanumeric: a-z, A-Z, 0-9
     _ in place of horizontal tab
Squeezed files will be searched as well as unsqueezed
ones. Use ^C to quit, any other key skips rest of file.
 FFYNDE.COM 08/01/84 ICUAP
 -- Bad Pattern -- 
-- Search Terminated --  -- Remainder of File Skipped --
 .COM file disregarded.
 .CMD file disregarded.
  -- Code Table Won't Fit --
 .XRF file disregarded.
  -- Can't Open Keyword File --
  -- Crossreference File Already Exists --
  -- Can't Open Crossreference File --
  -- Write Error in Crossreference File --
  -- Can't Close Crossreference File --
  DFilenameEXT                                       Keyword is:                                                                  [original] : original.xxx
 ------> File xxxxxxxx.xxx
       +             0      lines found
       instances in the entire disk
       keywords processed
                                                                                                                                                  