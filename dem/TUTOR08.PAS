program Tutor08;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   CRT,
   GSOB_DBF,
   GSOB_VAR;
var
   MyFile  : GSO_dBaseFld;
   MNum    : real;
begin
   ClrScr;
   MNum := 0;
   MyFile.Init('TUTOR1');
   MyFile.Open;
   MyFile.GetRec(Bttm_Record);
   MyFile.NumberPut('PAYMENT',1234.56);
   MyFile.PutRec(MyFile.RecNumber);
   MyFile.GetRec(Top_Record);
   while not MyFile.File_EOF do
   begin
      MNum := MNum + MyFile.NumberGet('PAYMENT');
      writeln(MyFile.DelFlag:6,'  ',MyFile.RecNumber:4,'  ',
              MyFile.FieldGet('LASTNAME'),'  ',
              MyFile.FieldGet('PAYMENT'));
      MyFile.GetRec(Next_Record);
   end;
   writeln('TOTAL':44,'  ',MNum:9:2);
   MyFile.Close;
end.
