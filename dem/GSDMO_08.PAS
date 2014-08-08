Program GSDMO_08;
{------------------------------------------------------------------------------
                          DBase File Structure Lister


       -------------------------------------------------------------
            _______
           /_   __/____
            / //_   __/
           /_/hE  /
               /_/oY! '96 proudly presents: 'Halcyon/2'
                         Vp & Os/2 compatible!
       -------------------------------------------------------------

       This program demonstrates how dBase file structures may be listed
       using Halcyon/2 units.

       The program opens a dBase file and lists all fields from each
       record along with its structure.

       New procedures/functions introduced are:

                 Deleted
                 Field
                 FieldCount
                 FieldDec
                 FieldGetN
                 FieldLen
                 FieldType
                 LUpdate
                 RecCount
                 RecNo

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
   MFields : integer;
   Ch      : char;
begin
   Ch := ' ';
   SetCenturyOn;
   Select(1);
   Use('GSDMO_07');
   GoTop;
   while (not dEOF) and (Ch <> #27) do     {loop until EOF or ESC pressed}
   begin
      ClrScr;
      Writeln('Record Number ',RecNo ,' of ',RecCount);
      Writeln;
      for MFields := 1 to FieldCount do
         writeln(MFields:3,'  [',
                 FieldType(MFields),'] [',
                 FieldLen(MFields):2,',',
                 FieldDec(MFields):1,']  ',
                 Field(MFields):10,': ',
                 FieldGetN(MFields));
      writeln;
      writeln('Deleted Status = ',Deleted);
      writeln('Last Update: ',LUpdate);
      Ch := ReadKey;                    {wait for keypress}
      Skip(1);
   end;
   CloseDataBases;
end.
