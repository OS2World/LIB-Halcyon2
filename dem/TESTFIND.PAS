program TestFind;
{------------------------------------------------------------------------------
                          DBase File Index Find

       -------------------------------------------------------------
       This program demonstrates how dBase files may use the Find call.

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
   NameIn  : string;

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
                {and Index('TESTFIND') used to open the index}

   IndexOn('TESTFIND','LASTNAME+FIRSTNAME');

{   Index('TESTFIND');}

   GoTop;
   while not dEOF do
   begin
      writeln(FieldGet('LASTNAME'),' ',
              FieldGet('FIRSTNAME'),'  ',
              FieldGet('BIRTHDATE'));
      Skip(1);
   end;
   namein := '';
   repeat
      write('Enter Name to Find (Case Sensitive): ');
      readln(namein);
      if namein <> '' then
      begin
         Find(namein);
         if Found then
            writeln('Record Found - ',
                    FieldGet('LASTNAME'),' ',
                    FieldGet('FIRSTNAME'))
         else Writeln('No Match!!');
      end;
   until namein = '';
   CloseDataBases;
   write('Press any Key to continue:');
end.
