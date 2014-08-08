program TUTOR03;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   CRT,
   GSOB_DBF;
var
   MyFile  : GSO_dBaseFld;
   s1,
   s2      : string[30];
   s3      : string[8];

begin
   ClrScr;
   MyFile.Init('TUTOR1');
   MyFile.Open;

   s1 := 'ThisIsALastName';
   s2 := 'HereIsAFirstName';
   s3 := '08/11/92';

   MyFile.Blank;
   Myfile.StringPut('LASTNAME',s1);
   Myfile.StringPut('FIRSTNAME',s2);
   Myfile.StringPut('BIRTHDATE',s3);
   MyFile.Append;

   MyFile.Close;
end.
