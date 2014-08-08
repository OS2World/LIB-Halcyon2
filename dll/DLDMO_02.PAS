program DLDMO_02;
{------------------------------------------------------------------------------
                              DBase File Lister


       This program demonstrates how dBase files may be listed using
       VRGDBENG.DLL. It's the same as GSDMO_02 but uses a dinamic
       linking of the DB engine!
------------------------------------------------------------------------------}

{&Cdecl-}

uses USE32, Crt, VRGDBShl;

var c,i:longint;

begin
 ClrScr; i:= 0;

 if LoadDBModule then writeln('VRGDBENG.DLL loaded...')
  else begin
        writeln('VRGDBENG.DLL not loaded... error: ',DllError);
        Halt;
       end;

 if EnableAllDynalinks then writeln('All Dynalinks enabled!')
  else begin
        writeln(DllError,' errors occurred while enabling dynalinks');
        if ErrorList <> nil then
          for c := 1 to 140 do
           if ErrorList^[c] <> 0 then writeln(' - Error: ',ErrorList^[c],' on module no. ',c);
        Halt;
       end;

  if not FileExist('GSDMO_01.DBF') then   {Check for the file}
   begin
      writeln('File GSDMO_01.DBF not found.  Run GSDMO_01 to create.');
      if FreeDBModule then writeln('VRGDBENG.DLL disposed...')
       else writeln('VRGDBENG.DLL not disposed... error: ',DllError);
      halt;
   end;

  Select(1);                     {Use record area 1 (the default)}
  Use('GSDMO_01');               {Assign the dBase III file GSDMO_01}
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


 if FreeDBModule then writeln('VRGDBENG.DLL disposed...')
  else writeln('VRGDBENG.DLL not disposed... error: ',DllError);

end.
