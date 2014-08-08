program GSDMO_09;
{------------------------------------------------------------------------------
                              DBase Index Creator

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       Unit to demonstrate more complex index processing.

       The GSDMO_09.DBF file will be created, if it does not exist, by
       using the MakeTestData procedure in GSOB_GEN.PAS.

       The IndexOn routine will be used to index on LASTNAME.  This can
       be commented out after the index is created and just  use the
       index by the command: Index('GSDMO_09').

       The indexed file will be listed ascending and descending.

       Finally, Find is called using the LASTNAME in physical record
       35.  The record number of the first occurrence of the name will
       be returned.  This may be record 35, or an earlier record if one
       exists with the same last name.

       New procedures/functions introduced are:

                 dBOF
                 Find
                 GoBottom
                 TrimR

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_Gen,
   GSOB_Str,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}

var
   s       : string;
   li      : boolean;
   i       : integer;
   oi      : integer;
   c       : char;
   ms      : string[30];
begin
   ClrScr;

   if not FileExist('GSDMO_09.DBF') then
   begin
      writeln('Creating GSDMO_09.DBF');
      MakeTestData(3,'GSDMO_09', 50, false);
      writeln('GSDMO_09.DBF Created');
   end;

   Select(1);
   Use('GSDMO_09');
   IndexOn('GSDMO_09','LASTNAME');

   i := 0;
   GoTop;
   while (not dEOF) do
   begin
      inc(i);
      if (i mod 23) = 0 then
      begin
         write('Press any key to continue.');
         c := ReadKey;
         writeln;
      end;
      s := FieldGet('LASTNAME');
      writeln(RecNo:8,'   ',s,i:6);    {Write the record number}
      Skip(1);
   end;
   writeln('End of Ascending check, Now for descending...');
   writeln('Press any key to continue.');
   c := ReadKey;
   i := 0;

   GoBottom;                   {Now get the last record in the file}
   while (not dBOF) do         {Repeat until at the beginning of file}
   begin
      inc(i);
      if (i mod 23) = 0 then
      begin
         write('Press any key to continue.');
         c := ReadKey;
         writeln;
      end;
      s := FieldGet('LASTNAME');
      writeln(RecNo:8,'   ',s,i:6);
      if RecNo = 35 then ms := s;
      Skip(-1);                 {Resd the previous record}
   end;

   ms := TrimR(ms);
   Find(ms);
   writeln('The first record for ',ms,' is ',RecNo);
   CloseDataBases;
end.

