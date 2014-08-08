Program Tutor04;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   CRT,
   GSOB_DBF;
var
   MyFile  : GSO_dBaseFld;
   MFields : integer;
begin
   ClrScr;
   with MyFile do
   begin
      Init('TUTOR1');
      Open;
      for MFields := 1 to NumFields do
         writeln(MFields:3,'   ',
                 FieldName(MFields),'  ',
                 FieldType(MFields),'  ',
                 FieldLength(MFields),'  ',
                 FieldDecimals(MFields));
      Close;
   end;
end.
