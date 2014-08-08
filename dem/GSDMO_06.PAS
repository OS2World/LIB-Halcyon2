program GSDMO_06;
{------------------------------------------------------------------------------
                              DBase File Indexing

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how dBase files may be indexed using
       Griffin Solutions units.

       If the GSDMO_01.DBF file does not exist, the program will display a
       a message that the file was not found and to run GSDMO_01 to make
       the file.

       The program opens a dBase file, creates an index on LASTNAME,
       and proceeds to list selected fields from each record in LASTNAME
       sequence.

       New procedures/functions introduced are:

                 Index
                 IndexOn

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}


var MIndx : Integer;
begin
   ClrScr;
   if not FileExist('GSDMO_01.DBF') then
   begin
      writeln('File GSDMO_01.DBF not found.  Run GSDMO_01 to create.');
      halt;
   end;
                       {The 'Real' example starts here}

   Select(1);
   Use('GSDMO_01');

                {use IndexOn to create the index}
                {This is only needed the first time through}
                {It can be commented out for future runs}
                {and Index('GSDMO_06') used to open the index}

   IndexOn('GSDMO_06','LASTNAME');

   {Index('GSDMO_06');}

   GoTop;
   while not dEOF do
   begin
      writeln(FieldGet('LASTNAME'),' ',
              FieldGet('FIRSTNAME'),'  ',
              FieldGet('BIRTHDATE'));
      Skip(1);
   end;
   CloseDataBases;
   write('Press any Key to continue:');
   repeat until KeyPressed;
end.
