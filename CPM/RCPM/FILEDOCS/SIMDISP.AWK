# SIMDISP.AWK
# Author: Joseph Gil (yogi@humus.huji.ac.il.BITNET)
BEGIN {
    FS = "\"";
    INDENT_UNIT = "  ";
}
{
    curr_drive =  $2;
    curr_dir = substr($4,2,length($4)-2);
    split(curr_dir,split_dir,".");

    INDENT_LEVEL = "";
    if (curr_drive != prev_drive) {
        print INDENT_LEVEL curr_drive;
        prev_drive = curr_drive;
        prev_main_dir = "";
        prev_sec_dir = "";
    }
    INDENT_LEVEL = INDENT_LEVEL INDENT_UNIT;
    if (split_dir[1] != prev_main_dir) {
        print INDENT_LEVEL split_dir[1];
        prev_main_dir = split_dir[1];
        prev_sec_dir = "";
    }
    INDENT_LEVEL = INDENT_LEVEL INDENT_UNIT;
    if (split_dir[2] != prev_sec_dir) {
        print INDENT_LEVEL split_dir[2];
        prev_sec_dir = split_dir[2];
    }
    INDENT_LEVEL = INDENT_LEVEL INDENT_UNIT;
    split($7,numb,",");
	size = numb[3];
	if (size < 1024) {
		size = sprintf("%4d",size);
	} else if (size < 1024*1024) {
		size /= 1024;
		size += 0.5;
		size = int(size);
		size = sprintf("%3dK",size);
	} else {
		size /= 1024 * 1024;
		size += 0.5;
		size = int(size);
		size = sprintf("%3dM",size);
	}
	date = numb[5];
    printf("%s%-12s %4s %6s %s\n",INDENT_LEVEL,$6,size,date "",$8);
}
