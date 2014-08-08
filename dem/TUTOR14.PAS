Program Tutor14;
uses
   USE32,
   CRT,
   GSOB_DBF,
   GSOB_DBS,
   GSOB_VAR;
var
   MyFile  : GSO_dBHandler;
   MFields : integer;
   s       : string;
begin
   ClrScr;
   MyFile.Init('TUTOR1');
   MyFile.Open;
   MyFile.Index('TUTOR1LN');
   MyFile.GetRec(Top_Record);     {Get the first record in the file}
   while not MyFile.File_EOF do   {Repeat until end-of-file}
   begin
      writeln(MyFile.FieldGet('LASTNAME'));
      MyFile.GetRec(Next_Record); {Get the next sequential record}
   end;
   writeln;
   write('Enter name to find: ');
   readln(s);
   if MyFile.Find(s) then
   begin
      Writeln('Record Number ',MyFile.RecNumber,' of ',MyFile.NumRecs);
      Writeln;
      for MFields := 1 to MyFile.NumFields do
         writeln(MFields:3,'   ',
                 MyFile.FieldName(MFields):10,': ',
                 MyFile.FieldGetN(MFields));
      writeln;
      writeln('Deleted Status = ',MyFile.DelFlag);
   end
   else
      writeln('No Match');
   MyFile.Close;
end.
