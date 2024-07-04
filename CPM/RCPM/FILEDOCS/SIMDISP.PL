#!/usr/local/perl
#
# simdisp.pl
#
# Prints the SIMTEL file simibm.idx
#
# 900106  Bo Kullmar, bk@kullmar.se
format top =
                         Directory @<<<@<<<<<<<<<<<<<<<<<<<<         Page:@>>
                                   $dev$dir                               $%
Filename    Type Length  Date    Description
===============================================================================
.
format STDOUT =
@<<<<<<<<<<<<@<<<@>>>>>  @<<<<<  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$file,       $at,$size,  $date,  $comment
.

$simfile = "simibm.idx";
@st = lstat($simfile);
$sim_time=&fmt_time($st[9]);

print "WSMR-SIMTEL20.ARMY.MIL PUBLIC DOMAIN LISTING AS OF $sim_time\n\n";
print "NOTE: Type B is Binary; Type A is ASCII\n\n";
$s- = $s- - 4;

open(in, $simfile);		# Open simibm.idx
while (<in>)			# Read one line
{
	chop;			# Remove trailing LF
        ($dev,$dir,$file,$dummy,$size,$type,$date,$comment) = split(/,/,$_,8);
        $dev = substr($dev,1,length($dev)-2);
        $dir = substr($dir,1,length($dir)-2);
        $file = substr($file,1,length($file)-2);
        $comment = substr($comment,1,length($comment)-2);
        if ($type==8) {
            $at= "B";

        }
        else {
            $at= "A";
        }
        if ( $ldev ne $dev || $ldir ne $dir ) {		# New page
            if ( $- < 6 ) {
               $- = 0;
            }
            else {
               print "\n                         Directory $dev$dir\n";
               print "Filename    Type Length  Date    Description\n";
               print "===============================================================================\n";
	       $- = $- - 4;
            }
        }
        write();		# Write the line
        $ldev = $dev;
        $ldir = $dir;

}


sub fmt_time {
  local ($time) = shift (@_);
  local (@tm) = localtime ($time);
  local ($cent);
  if ($tm[5] < 70) {
     $cent = "20";
  }
  else {
     $cent = "19";
  }
  return
  sprintf ("%s%02d-%02d-%02d %02d:%02d",
		 $cent, $tm[5], $tm[4]+1, $tm[3], $tm[2], $tm[1]);

}

