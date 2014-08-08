Program Tutor13;
uses USE32,   CRT,
   GSOB_DBF,
   GSOB_DBS,
   GSOB_VAR;

{$Dynamic System}
{$L VRGDBENG.LIB}

var
   MyFile  : GSO_dBHandler;
   MIndx   : integer;
begin
   ClrScr;
   MyFile.Init('TUTOR1');
   MyFile.Open;
   MIndx := MyFile.IndexTo('TUTOR1LN','LASTNAME');
   MyFile.GetRec(Top_Record);     {Get the first record in the file}
   while not MyFile.File_EOF do   {Repeat until end-of-file}
   begin
      writeln(MyFile.FieldGet('LASTNAME'),' ',
              MyFile.FieldGet('FIRSTNAME'),'  ',
              MyFile.FieldGet('BIRTHDATE'));
      MyFile.GetRec(Next_Record); {Get the next sequential record}
   end;
   MyFile.Close;
end.
