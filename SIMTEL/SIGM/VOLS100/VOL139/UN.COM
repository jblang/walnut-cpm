Ñ   


	*****  Hi there!  *****

  The purpose of this program is to enable the UN-protecting of
  Microsoft Basic programs.  It is hoped that the users of this
  program bear in mind that the authors' intent in the distri-
  bution of UN.COM is that it be used for the recovery of their
  own progams.  Certain unscrupulous souls will undoubtedly try
  to 'rip off' commercial software if they can reasonably do so,
  and programs such as this can certainly be used for such ends.
	  In spite of the such possible abuses, UN is being released,
  for the following reasons:
  1  -  Programs such as this have been on the market for almost
	     one year (as of 06/81) from several sources.  Presumably,
	     you honest folk are the last to hear about or obtain such
	     things.  Outlaw powerful programs and only the Outlaws...
	     (Ugh, I didn't really say that, did I? Oh well...)
  2  -  The release of Bascom, version 5.3, appears to signal the
	     end of the nefarious royalty requirement, as the run time
	     package is now being sold seperately, and doesn't have to
	     be linked with the compiled (read 'protected') programs.
	     ( And for the lowest possible end user cost, don't forget
	     about the reliable and speedy Fortran and BDS C compilers)
  3  -  It's nice to demonstrate that low cost doesn't imply lower
	     performance.  UN.COM has several advantages over the higher
	     priced spreads.
	   A - It works with all versions of MBASIC 5.x tested to date.
	   B - Once invoked, it remains permanently active, until the
	       user deactivates UN, or until the next cold boot.  (You
	       don't have to load MBASIC 20 times in order to examine
	       20 protected programs.)
	   C - Large programs which barely fit in memory can be debugged
	       without the awkwardness of saving the program, and then
	       having to reload both the interpreter and the program.
	       This is possible because UN modifies only the system, and
	       occupies no TPA space. (Type 'PRINT FRE(I)' to see if
	       several thousand bytes of program space have been lost.)
	   D - The licensing terms are modest.  The end user agrees that
	       HE/SHE will make no more than 600 copies for their own
	       personal use, and that no limit is placed on the number
	       of copies distributed elsewhere.
	   E - If because of your systems' peculiarities UN.COM doesn't
	       work, you haven't lost much...
  And now for the rules of the game...

	   To invoke UN.COM, type 'UN DO' 
	   To deactivate UN.COM, type 'UN NO' 
	   To UN-protect a program, first get it into memory with the
		'LOAD' command, and then type ^U  (control-U).  The
		program is now unprotected and may be listed or saved.
	   UN.COM now performs more extensive error checking and
		works under both CP/M and CDOS.
$ 
      Honk if you %!$#*& ZOSO.
      Bye  -  B.R.N. 07/12/81

                                                                                                                       �:^ �O�C�	���.��!��!��!�!��! �! �����>����w���w#�|��8���I:] �D�q*  ���y:	 ���p!& ~���p�9!
 �i��! �i�  * +%%� 0�͢��! >��7�& >�w?#��"�##"��"7gl"7��3�Y��:] �X��*_ >Z������:a �Y��! �i�  �H¾:] �W��*_ >U���>O���:7 �1�,=27 4�97�9!	 �i4�9�  >127 ��
$ $	��� ���=��E��:] �H��*_ >P���>L�L���
	� �  :] �N��*  ��2Fʌ=2F:	 ��¬�==�͢��´(  *����> 2�ÿ!& ~���%:	 �!��: �!��:( �!��:F� �
:�����! �i�  ! �i����!!	 p#>����! �i�  !  9. %%%%+���*
 �*  	s#r��! �i�  >�w> �� ]����)?g��,B�MQ5/�����*8��0m;��i�6�VN�2����SO/3������0����OO?1�ސ�l4Z�CkI嗍�,
��4ױ�E���������Gm7�����Nl��X>P�[o;�=S}�*��<�{;�ų!F~$���"����Ww7����B�����Ii	)���&Hf�9#Q��Bv ���>3e'��c���d�Ј�Gu�+�ۻ�F\��F N`������F
T҄�}o��峑~��\�v����o+E��Vn�p��w�ua�m�3~`���"Qs�#��-Rp�|���kw?��r�2��I3]3� ����(/!ma�k��@v�@�v���E@|,Xd~�
��}_�_� >027 :] �?�f! �i�  UN.COM for SIG/M via HK (no good on Heath). 12,81  - b.n. -   $�!�2*  ^#V�"
>	!	 	.w#�X! �i�  +)G"|##"x*0�*0��~����#{��~�GÂ                                                                                                            