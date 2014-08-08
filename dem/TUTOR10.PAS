program Tutor10;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   CRT,
   GSOB_DTE,
   GSOB_DBF,
   GSOB_VAR;
var
   MyFile  : GSO_dBaseFld;
begin
   ClrScr;
   SetCentury(DBOn);              {Displays 4-character year (e.g., 1992)}
   MyFile.Init('TUTOR1');
   MyFile.Open;
   MyFile.GetRec(Top_Record);
   while not MyFile.File_EOF do
   begin
      writeln(MyFile.DelFlag:6,'  ',MyFile.RecNumber:4,'  ',
              MyFile.DateGet('BIRTHDATE'):10,'  ',
              MyFile.StringGet('BIRTHDATE'),'  ',
              GS_Date_View(MyFile.DateGet('BIRTHDATE')+90));
      MyFile.GetRec(Next_Record);
   end;
   MyFile.Close;
end.
