
MODULE Strtest;
FROM Terminal IMPORT WriteString,WriteLn,Write,Read;
FROM InOut IMPORT ReadCard,WriteCard;
FROM Strlib IMPORT Len,StringAdd,StringLeft,StringRight,InputString,
     StringRemove,StringDelete,StringInsert,ShowString,StringPos,StringReplace,
     StringChange,eos;
 
VAR 
     j,k : CARDINAL;
   Str1, Str2, Str3 : ARRAY [0..79] OF CHAR;  
      chr : CHAR;
 
 
BEGIN
    WriteString("Enter a String : "); InputString(Str1); WriteLn;
    WriteString("Your string is "); WriteCard(Len(Str1),2);
    WriteString(" characters long"); WriteLn;
    WriteString("Append a string to the first one : "); InputString(Str2);
    WriteLn; WriteLn;
    StringAdd(Str1,Str2);
    WriteString("The new string is:"); WriteLn;
    ShowString(Str1); WriteLn;
    WriteString("Enter first and last character to be deleted, by position ");
    WriteLn;ReadCard(j); 
    WriteLn; ReadCard(k); WriteLn;
    StringDelete(Str1,j,k); WriteLn;
    WriteString("Your string is now "); WriteLn; ShowString(Str1); WriteLn;
    WriteString("The last two characters are : "); StringRight(Str2,Str1,2);
    ShowString(Str2); WriteLn;
    WriteString("The first two characters are : "); StringLeft(Str2,Str1,2);
    ShowString(Str2); WriteLn; WriteLn;
    WriteString("Enter string to be removed : "); InputString(Str2); WriteLn;
    StringRemove(Str1,Str2);
    WriteString("Your string is now :"); WriteLn; ShowString(Str1); WriteLn;
    WriteString("Enter string to be inserted "); InputString(Str2); WriteLn;
    WriteString("Enter position of insertion "); WriteLn; ReadCard(j);
    WriteLn;
    StringInsert(Str1,Str2,j);
    WriteString("Your string is now : "); ShowString(Str1); WriteLn;
    WriteString("Enter string to be replaced "); InputString(Str2); WriteLn;
    WriteString("Enter the replacing string "); InputString(Str3); WriteLn;
    StringReplace(Str1,Str2,Str3);
    WriteString("Your string is now : "); ShowString(Str1); WriteLn;
   
    WriteLn; WriteLn; WriteString("----------End of Program------------");
    WriteLn; WriteLn;
END Strtest.

