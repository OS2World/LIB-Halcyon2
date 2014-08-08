program GSDMO_10;
{------------------------------------------------------------------------------
                             DBase Multiple Indexes

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       Unit to demonstrate multiple index processing.  The indexes are
       first created and then updated with more records to demonstrate
       multiple indexes may be updated when a dBase record is added or
       updated.

       The GSDMO_10.DBF file will be created by using the MakeTestData
       procedure in GSOB_GEN.PAS.

       The IndexOn routine will be used to make index GSDMO10A.NDX on
       LASTNAME+FIRSTNAME and index GSDMO10B.NDX on BIRTHDATE.

       The indexed file will be listed ascending using GSDM010A.

       Additional Records will be added to test multiple index update.

       Finally, the file will be listed again in LASTNAME+FIRSTNAME and
       BIRTHDATE index sequence.  Note the use of SetOrderTo to switch
       between which index is the master.

       New procedures/functions introduced are:

                 DBFActive
                 SetOrderTo

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
   s       : string;
   li      : boolean;
   i       : integer;
   c       : char;
   jd      : longint;
   ms      : string[30];
   ix1     : integer;
   ix2     : integer;

begin
   ClrScr;

   writeln('Creating GSDMO_10.DBF');
   MakeTestData(3,'GSDMO_10', 50, false);
   writeln('GSDMO_10.DBF Created');

   SetCenturyOn;
   Select(1);
   Use('GSDMO_10');

   IndexOn('GSDMO10A','LASTNAME+FIRSTNAME');
   IndexOn('GSDMO10B','BIRTHDATE');
   Index('GSDMO10A, GSDMO10B');     {Assign both indexes to the database}
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

   writeln('End of File, Now for More Records...');
   writeln('Press any key to continue.');
   c := ReadKey;

   writeln('Adding GSDMO_10.DBF Records');
   AddTestData(DBFActive, 50);  {DBFActive is a pointer to current DBF object}
   writeln('GSDMO_10.DBF Records Added');

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

   writeln('End of File, Now to check date sequence...');
   writeln('Press any key to continue.');
   c := ReadKey;

   SetOrderTo(2);                      {Now change to the GSDMO10B index}
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
   CloseDataBases;
end.
