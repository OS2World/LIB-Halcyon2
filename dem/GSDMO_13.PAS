program GSDMO_13;
{------------------------------------------------------------------------------
                         DBase Relational File Linkage

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This unit demonstrates how to search for multiple records with a
       common identifier.

       The master file index is on the LASTNAME+FIRSTNAME fields.  The
       transaction record is located by matching the master record UNIQUEID
       to the MASTERID field of the transaction record.

       The routine will read each master record and list all transactions
       with the master record unique identifier.

-------------------------------------------------------------------------------}

uses
   USE32,
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
   ch : char;
   mfileid : string[8];

begin
   ClrScr;
   ch := ' ';

   if not FileExist('GSDMO_MF.DBF') then
   begin
      writeln('File GSDMO_MF.DBF not found.  Run GSDMO_11 to create.');
      halt;
   end;

   if not FileExist('GSDMO_TF.DBF') then
   begin
      writeln('File GSDMO_TF.DBF not found.  Run GSDMO_11 to create.');
      halt;
   end;

                       {The 'Real' example starts here}

   Select(1);
   Use('GSDMO_MF');
   Index('GSDMO_NM');
   Select(2);
   Use('GSDMO_TF');
   Index('GSDMO_TN');

   Select(1);
   GoTop;
   while not (dEOF) and (Ch <> #27) do
   begin
      ClrScr;
      mfileid := FieldGet('UNIQUEID');
                   {Display the master record}

      Writeln('':37,'MASTER');
      Writeln;
      Writeln('  LASTNAME : ',FieldGet('LASTNAME'));
      Writeln(' FIRSTNAME : ',FieldGet('FIRSTNAME'));
      Writeln('    STREET : ',FieldGet('STREET'));
      Writeln('   ADDRESS : ',StringGet('CITY'),', ',
                              FieldGet('STATE'),' ',
                              FieldGet('ZIP'));

                       {Display transaction information}

      Writeln;
      Writeln('':20,'-----------------------------------------');
      Writeln('':34,'TRANSACTION');
      Writeln;

                       {Hunt for matching records}

      Select(2);
      Find(mfileid);
      if Found then
      begin
         while ((mfileid) = FieldGet('MASTERID')) and not dEOF do
         begin
            Writeln(FieldGet('FULLNAME'),'  ',
                    DTOC(DateGet('TRANDATE')),'  ',
                    FieldGet('AMOUNT'),'       [',
                    RecNo:2,']');
            Skip(1);
         end;
      end
      else Writeln('No Transaction Records!');

      Writeln;
      Writeln('Press Any Key to Continue: ') ;
      Writeln('[ESC] Will Terminate the Program');
      ch := ReadKey;
      Select(1);
      Skip(1);
   end;
   CloseDataBases;
end.
