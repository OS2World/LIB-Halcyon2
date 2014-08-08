program GSDMO_05;
{------------------------------------------------------------------------------
                             DBase File Appending

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how dBase files may be appended using
       Griffin Solutions units.

       If the GSDMO_01.DBF file does not exist, the program will display a
       a message that the file was not found and to run GSDMO_01 to make
       the file.

       The program opens a dBase file, appends a record, and proceeds to
       list selected fields from each record.

       New procedures/functions introduced are

                 Append
                 ClearRecord
                 Date
                 DatePut

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


const
   s1 = 'ALastName';
   s2 = 'FirstNameMI';

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

                 {Insert a record}

   ClearRecord;                   {Put spaces in the record buffer area}
   StringPut('LASTNAME',s1);      {Store s1 in LASTNAME}
   StringPut('FIRSTNAME',s2);     {Store s2 in FIRSTNAME}
   DatePut('BIRTHDATE',Date);
                                  {Put today's date in BIRTHDATE}
   DBAppend;                      {Append the record to the end of the file}

                 {Now read the records}

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
