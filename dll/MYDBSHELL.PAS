unit MydbShell;
{------------------------------------------------------------------------------
                          DBase File Lister - Os/2 version
------------------------------------------------------------------------------}
{$Cdecl+}


Interface

PROCEDURE GO;

implementation
Uses Crt, GSOBSHEL;

var c,i:longint;
PROCEDURE GO;
BEGIN
 ClrScr; i:= 0;

  if not FileExist('GSDMO_01.DBF') then   {Check for the file}
   begin
      writeln('File GSDMO_01.DBF not found.  Run GSDMO_01 to create.');
      halt;
   end;

  Select(1);                     {Use record area 1 (the default)}
  writeln('ok');
  Use('GSDMO_01');               {Assign the dBase III file GSDMO_01}
  writeln('ok');
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
END;
END.

