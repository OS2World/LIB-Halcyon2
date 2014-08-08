Program Tutor11;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   CRT,
   GSOB_DBF,
   GSOB_VAR;
var
   MyFile  : GSO_dBaseFld;
   MFields : integer;
   Ch      : char;
begin
   Ch := ' ';
   with MyFile do
   begin
      Init('TUTOR1');
      Open;
      GetRec(Top_Record);
      while (not File_EOF) and (Ch <> #27) do
      begin
         ClrScr;
         Writeln('Record Number ',RecNumber,' of ',NumRecs);
         Writeln;
         for MFields := 1 to NumFields do
            writeln(MFields:3,'   ',
                    FieldName(MFields):10,': ',
                    FieldGetN(MFields));
         writeln;
         writeln('Deleted Status = ',DelFlag);
         Ch := ReadKey;                    {wait for keypress}
         GetRec(Next_Record);
      end;
      Close;
   end;
end.
