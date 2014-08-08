program GSDMO_02;
{------------------------------------------------------------------------------
                              DBase File Lister

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how dBase files may be listed using
       Griffin Solutions units.

       If the GSDMO_01.DBF file does not exist, the program will display a
       a message that the file was not found and to run GSDMO_01 to make
       the file.

       The program opens a dBase file and proceeds to list selected fields
       from each record.

       New procedures/functions introduced are:

                 CloseDataBases
                 dEOF
                 FieldGet
                 FileExist
                 GoTop
                 Select
                 Skip
                 Use

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

var i:longint;

begin
   ClrScr; i:= 0;
   if not FileExist('GSDMO_01.DBF') then   {Check for the file}
   {For long names test only: }
   {if not FileExist('LONG_GSDMO_01.DBFIV.DBF') then}
   begin
      writeln('File GSDMO_01.DBF not found.  Run GSDMO_01 to create.');
      halt;
   end;
                       {The 'Real' example starts here}

   Select(1);                     {Use record area 1 (the default)}
   Use('GSDMO_01');               {Assign the dBase III file GSDMO_01}
   {Use('LONG_GSDMO_01.DBFIV');}
   GoTop;                         {Get the first record in the file}
   while not dEOF do              {Repeat until end-of-file}
   begin
      inc(i);
      writeln(FieldGet('LASTNAME'),' ',       {Get field images}
              FieldGet('FIRSTNAME'),'  ',
              FieldGet('BIRTHDATE'));
      Skip(1);                    {Get the next sequential record}
      if i >=23 then begin
        readln;
        i := 0;
       end; {if i...}
   end;
   CloseDataBases;                {Close the file}
   write('Press any Key to continue:');
   repeat until KeyPressed;
end.
