program TUTOR02;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   CRT,
   GSOB_DBF,
   GSOB_VAR;
var
   MyFile  : GSO_dBaseFld;
   i       : integer;
   s1,
   s2      : string[30];

procedure WorkTheFile;            {reads the file, reverses LASTNAME, }
                                  {displays fields, and writes the record}
begin
   MyFile.GetRec(Top_Record);     {Get the first record in the file}
   while not MyFile.File_EOF do   {Repeat until end-of-file}
   begin
      s1 := MyFile.StringGet('LASTNAME');
      s2 := '';
      for i := 1 to length(s1) do s2 := s1[i] + s2;
      Myfile.StringPut('LASTNAME',s2);
      writeln(s2,', ',
              MyFile.StringGet('FIRSTNAME'));
      MyFile.PutRec(MyFile.RecNumber);
      MyFile.GetRec(Next_Record); {Get the next sequential record}
   end;
end;

{------ Main Routine ------}

begin
   ClrScr;
   MyFile.Init('TUTOR1');
   MyFile.Open;
   WorkTheFile;
   MyFile.Close;
end.
