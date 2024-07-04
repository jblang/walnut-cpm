 #include <io.h>
 #include <stdio.h>
 #include <fcntl.h>

 main()
 {
     char in_file[13];
     char out_file[13] = "outfile.txt";
     int c;
     char newc;

     FILE *fp_in, *fp_out;

     printf ("Filename to convert:");
     scanf("%s", &in_file);
     printf ("\nSave to:");
     scanf ("%s",&out_file);

     printf ("IN FILENAME -> %s", in_file);
     printf ("\nOUT FILENAME -> %s\n", out_file);


     fp_in = fopen(in_file, "rb");
     fp_out = fopen (out_file, "w");

     while ((c = getc(fp_in)) != EOF)
     {

          /* Graphics to UpperCase */
          if ((c > 192) && (c < 219)) {
               newc = c - 128;
          }

          /* Upper To Lower case */
          else if ((c >= 'A') && (c <= 'Z')) {
               newc = c + 32;
          }

          else if (c == 13) {
               newc = '\n';
          }
          else newc = c;

          /* Newline */
          putchar (newc);
          fputc (newc, fp_out);

     }

     /*that's all folks */
 }
