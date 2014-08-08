program GSDMO_04;
{------------------------------------------------------------------------------
                             DBase File Updating

       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how dBase fields may be modified using
       Griffin Solutions units.

       If the GSDMO_01.DBF file does not exist, the program will display a
       a message that the file was not found and to run GSDMO_01 to make
       the file.

       The program opens a dBase file and proceeds to list selected fields
       from each record.

       It will reverse all the letters in LASTNAME and write the record
       back to disk using Replace.

       Finally, it will read the file back in, list the new values, put
       the old LASTNAME back to the record by reversing letters again, and
       writing the record again.

       New procedures/functions introduced are:

                 Replace
                 StringPut

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

var
   i       : integer;
   s1,s2   : string[30];
   c       : char;

procedure WorkTheFile;            {reads the file, displays fields, and }
                                  {reverses LASTNAME                    }
begin
   GoTop;
   while not dEOF do
   begin
      s1 := StringGet('LASTNAME');
      writeln(s1,', ', StringGet('FIRSTNAME'));

      s2 := '';                   {Reverse the LASTNAME in s2}
      for i := 1 to length(s1) do s2 := s1[i] + s2;
      StringPut('LASTNAME',s2);   {Store s2 in LASTNAME}
      Replace;                    {Write buffer to current record}
      Skip(1);
   end;
end;


{------ Main Routine ------}

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
   WorkTheFile;
   writeln('------ Now to show LASTNAME is reversed in the file:');
   write('Press any Key to continue:');
   c := ReadKey;
   writeln;
   WorkTheFile;
   CloseDataBases;
   writeln('------ OK, the file is back in shape now');
   write('Press any Key to continue:');
   c := ReadKey;
end.
