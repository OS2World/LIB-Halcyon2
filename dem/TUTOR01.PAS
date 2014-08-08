
program Tutor01;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   CRT,
   GSOB_DBF,
   GSOB_VAR;

var MyFile  : GSO_dBaseFld;

begin
   ClrScr;
   MyFile.Init('TUTOR1');          {Initialize object using the dBase III}
                                   {file TUTOR1.  DBF Extension assumed}
   MyFile.Open;                    {Open the object's file}
   MyFile.GetRec(Top_Record);      {Get the first record in the file}
   while not MyFile.File_EOF do    {Repeat until end-of-file}
   begin
      writeln(MyFile.FieldGet('LASTNAME'),' ',
              MyFile.FieldGet('FIRSTNAME'),'  ',
              MyFile.FieldGet('BIRTHDATE'));
      MyFile.GetRec(Next_Record);  {Get the next sequential record}
   end;
   MyFile.Close;
end.
