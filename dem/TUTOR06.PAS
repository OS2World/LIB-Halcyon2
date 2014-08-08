program Tutor06;
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
   MyFile.GetRec(Bttm_Record);
   MyFile.Delete;              {Change to MyFile.UnDelete to reset record}
   MyFile.GetRec(Top_Record);
   while not MyFile.File_EOF do
   begin
      writeln(MyFile.DelFlag:6,'  ',
              MyFile.FieldGet('LASTNAME'),' ',
              MyFile.FieldGet('FIRSTNAME'),'  ',
              MyFile.FieldGet('BIRTHDATE'));
      MyFile.GetRec(Next_Record);
   end;
   MyFile.Close;
end.
