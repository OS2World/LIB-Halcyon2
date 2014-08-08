program TestFrm1;
{------------------------------------------------------------------------------
                                Formula Routine
                                Demo Program 1

       -------------------------------------------------------------

       The Formula routine in HALCYON only handles straight field names.
       However, the power of using objects is how simple it becomes to
       modifiy an ancestor object.  The following code, taken from demo
       program GSDMO_06.PAS, shows creating a child object with a virtual
       method Formula.  This method will be called anytime a formula is
       needed for an index action from anywhere within the ancestor
       object(s).

       In this example, the PAYMENT field is converted to a string of nine
       characters with two decimal places.  The BIRTHDATE field is then
       converted to a display format (YY/MM/DD) and appended to the string.
       The string is then returned as the formula's result.

       The IndexOn command must contain the correct formula; for example:
       "IndexOn('DEMOFRM1','STR(PAYMENT,9,2)+DTOC(BIRTHDATE)')", so
       it will be stored properly in the index header for use by other
       programs such as dBase, FoxPro, Clipper, etc.

-------------------------------------------------------------------------------}

uses
   USE32,
   GSOB_DBS,
   GSOBShel,
   {$IFDEF WINDOWS}
      WinCRT,
      WinDOS;
   {$ELSE}
      CRT,
      DOS;
   {$ENDIF}

{----------------------------------------------------------------------------}
{$F+}
Function UFormula(st: string; var fmrec: GSR_FormRec): boolean;
var FldCnt : integer;
begin
   if (fmrec.FAlias = 'TESTFRM1') then  {Correct Index?}
   begin                                       {Then set extract table}
      UFormula := true;
      for FldCnt := 0 to 32 do fmrec.FPosn[FldCnt] := 0;
      fmrec.FType := 'C';
      fmrec.FDcml := 0;
      fmrec.FSize := 17;           {PAYMENT = 9, BIRTHDATE = 8}
   end
   else UFormula := true;
end;

Function UFormXtract(var st: string; fmrec: GSR_FormRec): boolean;
begin
   if (fmrec.FAlias = 'TESTFRM1') then    {Correct index?}
   begin
      UFormXtract := true;
      str(NumberGet('PAYMENT'):9:2,st);
      st := st + DTOC(DateGet('BIRTHDATE'));
   end
   else UFormXtract := false;
end;
{$F-}
{----------------------------------------------------------------------------}



begin
   ClrScr;
   if not FileExist('GSDMO_01.DBF') then
   begin
      writeln('File GSDMO_01.DBF not found.  Run GSDMO_01 to create.');
      halt;
   end;

   Select(1);
   Use('GSDMO_01');
   SetFormulaProcess(UFormula, UFormXtract);
   IndexOn('TESTFRM1','STR(PAYMENT,9,2) + DTOC(BIRTHDATE)');
                           {formula is stored in index header}
   GoTop;
   while not dEOF do
   begin
      writeln(FieldGet('PAYMENT'),' ',
              FieldGet('BIRTHDATE'));
      Skip(1);
   end;
   SetFormulaProcess(DefFormulaBuild, DefFormulaXtract);
   CloseDataBases;
   write('Press any Key to continue:');
   repeat until KeyPressed;
end.

-----------------------------------------------------------------------------
                                     END

