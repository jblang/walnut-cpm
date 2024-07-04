Program SamplePatch;

{
  This program demonstrates how to use the program
   PATCH.COM to enable a Turbo Pascal program to
   access the CP/M command tail.

  Background: the Z80 versions of Turbo Pascal trash all
   but the first 32 bytes of the CP/M command tail in a
   .COM file.  Eliot Moss wrote PATCH.PAS to move the
   command tail to high memory; his program will repair
   any .COM file generated with Turbo version 2.0.  (The
   8088 versions do not share this problem since MS-DOS
   implements the command tail differently.  Also, the
   addresses are different in Z80 version 1.0.)

  Usage: write your .PAS source file the way you normally
   would.  Add the following lines:

    In the 'type' section:
      PatchString = string[127];

    In the 'var' section:
      CmdPtr  : ^PatchString absolute $DB;
      CmdTail : string[127];

    As the very first line of your main program:
      CmdTail := CmdPtr^;

  Assume your program source is FOO.PAS.  Compile your
   program into FOO.COM.  Exit from Turbo and type:
     PATCH FOO

  To use your file, type:  FOO these are the args to foo

  Written by   : Ferd S. Brundick
  Date written : 20 Jan 85
}

type
  PatchString = string[127];

var
  CmdPtr  : ^PatchString absolute $DB;
  CmdTail : string[127];

begin  { program SamplePatch }

{ copy CP/M command tail to a safe location }
  CmdTail := CmdPtr^;

{ display command tail to show that it is intact }
  writeln('Your command tail was:');
  writeln('|', CmdTail, '|')

end.  { program SamplePatch }
