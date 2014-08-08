program Tutor05;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   GSOB_DBF;
var
   MyFile : GSO_DB3Build;
begin
   with MyFile do
   begin
      Init('TUTOR5');
      InsertField('FIELD1','C',8,0);
      InsertField('SECOND','D',8,0);
      InsertField('THIRD','L',1,0);
      InsertField('FOURTH','N',6,2);
      Done;
   end;
end.
