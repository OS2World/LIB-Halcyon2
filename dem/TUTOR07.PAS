program Tutor07;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   CRT,
   GSOB_DBF,
   GSOB_VAR;
var
   MyFile  : GSO_dBaseFld;
begin
   ClrScr;
   MyFile.Init('TUTOR1');
   MyFile.Open;
   MyFile.GetRec(10);
   MyFile.Delete;              {Change to MyFile.UnDelete to reset record}
   SetDeleted(DBOn);
   MyFile.GetRec(Top_Record);
   while not MyFile.File_EOF do
   begin
      writeln(MyFile.DelFlag:6,'  ',MyFile.RecNumber:4,'  ',
              MyFile.StringGet('LASTNAME'),', ',
              MyFile.StringGet('FIRSTNAME'),'  ',
              MyFile.StringGet('BIRTHDATE'));
      MyFile.GetRec(Next_Record);
   end;
   MyFile.Close;
end.
