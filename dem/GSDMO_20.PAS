program GSDMO_20;
{------------------------------------------------------------------------------
                              DBase Reindexing

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       Unit to demonstrate Reindex. The indexes are first created and
       listed.  The indexes are then reindexed and listed again to
       show the Reindex procedure accurately reindexed all index files
       and assigned and maintained the proper master index order.

       New procedures/functions introduced are:

                 Reindex

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_Gen,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}

var
   i       : integer;
   j       : integer;
   c       : char;


procedure ListTheNames;
begin
   SetOrderTo(1);
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
      writeln(RecNo:8,'   ',FieldGet('LASTNAME'),i:6);
      Skip(1);
   end;
end;

procedure ListTheDates;
begin
   SetOrderTo(2);                      {Now change to the GSDMO24B index}
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
      writeln(RecNo:8,'   ',
              DTOC(DateGet('BIRTHDATE')),i:6);
      Skip(1);
   end;
end;


                  {----   Main Program ----}

begin
   ClrScr;
   SetCenturyOn;            {Needed to show full date}

   if not FileExist('GSDMO_20.DBF') then
   begin
      writeln('Creating GSDMO_20.DBF');
      MakeTestData(3,'GSDMO_20', 100, false);      {Make a dBase III file}
      writeln('GSDMO_20.DBF Created');
   end;

   Select(1);
   Use('GSDMO_20');
   IndexOn('GSDMO20A','LASTNAME');
   IndexOn('GSDMO20B','BIRTHDATE');

            {GSDMO20B should be the master as it was the last IndexOn}

   writeln('The master index is ',DBFActive^.IndexMaster^.dfFileName);
   j := 1;
   while DBFActive^.IndexStack[j] <> nil do
   begin
      writeln('Index ',j,' is ',DBFActive^.IndexStack[j]^.dfFileName);
      inc(j);
   end;
   writeln('Press any key to continue.');
   c := ReadKey;

   ListTheNames;

   writeln('End of File, Now to check date sequence...');
   writeln('Press any key to continue.');
   c := ReadKey;

   ListTheDates;

   writeln('End of File, Now to Reindex...');
   writeln('Press any key to continue.');
   c := ReadKey;

   SetOrderTo(1);             {GSDMO20A should be the master after reindex}
   Reindex;

   writeln('Reindexing complete.');
   writeln('The master index is ',DBFActive^.IndexMaster^.dfFileName);
   j := 1;
   while DBFActive^.IndexStack[j] <> nil do
   begin
      writeln('Index ',j,' is ',DBFActive^.IndexStack[j]^.dfFileName);
      inc(j);
   end;
   writeln('Press any key to continue.');
   c := ReadKey;

   ListTheNames;

   writeln('End of File, Now to check date sequence...');
   writeln('Press any key to continue.');
   c := ReadKey;

   ListTheDates;

   CloseDataBases;
end.
