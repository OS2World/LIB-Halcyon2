program Tutor12;
{$N+,E+}          {Required for floating point number handling}
uses
   USE32,
   CRT,
   GSOB_DBF,
   GSOB_DBS,
   GSOB_VAR;
var
   MyFile  : GSO_dBHandler;
   Ch      : char;

procedure ShowTheMemo;
var
   i,
   ml   : integer;
begin
   MyFile.MemoGet('COMMENTS');
   ml := MyFile.MemoLines;
   if ml > 20 then ml := 20;    {trim to fit the screen}
   if ml <> 0 then
      for i := 1 to ml do
         writeln(MyFile.MemoGetLine(i))
      else writeln('[ EMPTY ]');
   writeln;
end;

begin
   ClrScr;
   MyFile.Init('TUTOR1');
   MyFile.Open;
   MyFile.MemoWidth(75);     {sets width of the memo line.  Default is 50}
   MyFile.GetRec(Top_Record);
   while not MyFile.File_EOF do
   begin
      ClrScr;
      writeln(MyFile.FieldGet('LASTNAME'),', ',
              MyFile.FieldGet('FIRSTNAME'));
      ShowTheMemo;
      write('Press any key....');
      Ch := ReadKey;
      writeln;
      MyFile.GetRec(Next_Record);
   end;
   MyFile.Close;
end.
