// this program try to load/unload VRGDBENG.DLL for test purposes!

program DLDMO_01;
uses Use32, Crt, VRGDBSHL;
var c : longint;
begin
 ClrScr;
 writeln('Before LoadDBModule DllError = ',DllError);
 if LoadDBModule then writeln('VRGDBENG.DLL loaded...')
  else writeln('VRGDBENG.DLL not loaded... error: ',DllError);
 if EnableAllDynalinks then writeln('All Dynalinks enabled!')
  else begin
        writeln(DllError,' errors occurred while enabling dynalinks');
        if ErrorList <> nil then
          for c := 1 to 140 do
           if ErrorList^[c] <> 0 then writeln(' - Error: ',ErrorList^[c],' on module no. ',c);
       end;
 if FreeDBModule then writeln('VRGDBENG.DLL disposed...')
  else writeln('VRGDBENG.DLL not disposed... error: ',DllError);

writeln;
writeln('Now we try to load only one module without loading DLL... enter key to begin');
readln;

 if EnableDynalink(5) then writeln('Dynalink 5 enabled!')
  else writeln(DllError,' error occurred while enabling dynalink 5');
 if FreeDBModule then writeln('VRGDBENG.DLL disposed...')
  else writeln('VRGDBENG.DLL not disposed... error: ',DllError);


writeln;
writeln('And now we try to load only one module... enter key to begin');
writeln('(you will see as DllError is left with prev. error!');
readln;

 writeln('Before LoadDBModule DllError = ',DllError);
 if LoadDBModule then writeln('VRGDBENG.DLL loaded...')
  else writeln('VRGDBENG.DLL not loaded... error: ',DllError);
 if EnableDynalink(5) then writeln('Dynalink 5 enabled!')
  else writeln(DllError,' error occurred while enabling dynalink 5');
 if EnableDynalink(70) then writeln('Dynalink 70 enabled!')
  else writeln(DllError,' error occurred while enabling dynalink 70');
 if FreeDBModule then writeln('VRGDBENG.DLL disposed...')
  else writeln('VRGDBENG.DLL not disposed... error: ',DllError);


end.

