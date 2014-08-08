program Tutor09;
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
   MyFile.LogicPut('PAIDFLAG',true);
   MyFile.PutRec(MyFile.RecNumber);
   MyFile.GetRec(Top_Record);
   while not MyFile.File_EOF do
   begin
      write(MyFile.DelFlag:6,'  ',MyFile.RecNumber:4,'  ',
              'PAIDFLAG is Set ',
              MyFile.LogicGet('PAIDFLAG'));
      if MyFile.LogicGet('PAIDFLAG') then
         writeln('******')
      else writeln;
      MyFile.GetRec(Next_Record);
   end;
   MyFile.Close;
end.
