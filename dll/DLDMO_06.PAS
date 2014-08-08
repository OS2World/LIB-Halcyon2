program DLDMO_06;
{------------------------------------------------------------------------------
                          DBase File Lister - Os/2 version
------------------------------------------------------------------------------}
Uses Use32, Crt, GSOB_Var, GSOB_Str, GSOB_DBF, GSOB_DBS, GSOB_Dsk, GSOB_Dte;
     {,SysUtils;}{GSOBSHEL;}

{$DYNAMIC System, GSOB_Var, GSOB_Str, GSOB_DBF, GSOB_DBS, GSOB_Dsk, GSOB_Dte}
{ $ DYNAMIC System,GSOBSHEL}
{$L VRGDBENG.LIB}

var c,i:longint;

BEGIN
  ClrScr; i:= 0;
  if not FileExist('GSDMO_01.DBF') then   {Check for the file}
   begin
      writeln('File GSDMO_01.DBF not found.  Run GSDMO_01 to create.');
      halt;
   end;

end.

