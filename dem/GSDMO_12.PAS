program GSDMO_12;
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

       This unit demonstrates how to link the relationships between
       dBase files for data retrieval based on common fields in two files.

       The master file index is on the UNIQUEID field.  This will be used
       to get the master record based on the MASTERID field in the
       transaction record.

       The routine will read each transaction and display transaction
       information.  It will then find the correct master record and
       display master information.

       New procedures/functions introduced are:

                 Found
                 Strip_Flip

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

   Select(1);                          {Assign master file area}
   Use('GSDMO_MF');
   Index('GSDMO_ID');                  {Use the UNIQUEID key index}
   Select(2);                          {Switch to the transaction file area}
   Use('GSDMO_TF');
   GoTop;                              {Get the first transaction record}
   while not (dEOF) and (Ch <> #27) do {ESC will also end the run (#27)}
   begin
      ClrScr;
      mfileid := FieldGet('MASTERID');
                       {Display transaction information}

      Writeln('':34,'TRANSACTION');
      Writeln;
      Writeln('  FULLNAME : ',Strip_Flip(StringGet('FULLNAME')));
      Writeln('  TRANDATE : ',DTOC(DateGet('TRANDATE')));
      Writeln('    AMOUNT : ',FieldGet('AMOUNT'));
      Writeln('   PAYTYPE : ',FieldGet('PAYTYPE'));
      Writeln;
      Writeln('':20,'-----------------------------------------');
      Writeln('':37,'MASTER');
      Writeln;

                 {Now, go find the master record}

      Select(1);                   {Switch to the master file}
      Find(mfileid);               {Find the UNIQUEID key in the master file}
                                   {that matches the transaction MASTERID}
      if Found then                {Test for successful Find}
      begin
         Writeln('  LASTNAME : ',FieldGet('LASTNAME'));
         Writeln(' FIRSTNAME : ',FieldGet('FIRSTNAME'));
         Writeln('    STREET : ',FieldGet('STREET'));
         Writeln('   ADDRESS : ',StringGet('CITY'),', ',
                                 FieldGet('STATE'),' ',
                                 FieldGet('ZIP'));
      end
      else writeln('Cannot Find the Master Record!');

      Writeln;
      Writeln('Press Any Key to Continue: ') ;
      Writeln('[ESC] Will Terminate the Program');
      ch := ReadKey;
      Select(2);                       {Go back to the transaction}
      Skip(1);                         {and get the next record}
   end;
   CloseDataBases;
end.
